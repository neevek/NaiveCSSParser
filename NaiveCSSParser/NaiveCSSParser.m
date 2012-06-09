//
//  NaiveCSSParser.m
//  NaiveCSSParser
//
//  Created by neevek on 12-6-9.
//  Copyright (c) 2012 neevek. All rights reserved.
//

#import "NaiveCSSParser.h"
#import "CSSRule.h"

@implementation NaiveCSSParser
{
    NSMutableString *_selector;
    NSMutableString *_propertyName;
    NSMutableString *_propertyValue;
    NSMutableString *_quotedString;
    
    NSMutableSet *_ruleSet;
    
    int _prevState;
    int _state;
    unichar _prevChar;
    
    enum STATE {
        STATE_SELECTOR,
        STATE_PROPERTY_NAME,
        STATE_PROPERTY_VALUE,
        STATE_INSIDE_SINGLE_QUOTES,
        STATE_INSIDE_DOUBLE_QUOTES,
        STATE_INSIDE_BRACES,
        STATE_COMMENT
    };
}


#pragma mark State Machine Function Declarations
void collectSelector(const NaiveCSSParser *myself, unichar c);
void collectPropertyName(const NaiveCSSParser *myself, unichar c, const NSMutableDictionary *dict);
void collectPropertyValue(const NaiveCSSParser *myself, unichar c);

// example: url(http://abc.com/abc.png;sid=123?p=2)
// it is possible that url is not enclosed by quotes, so I have to handle text between brances separately
void collectTextInsideQuotes(const NaiveCSSParser *myself, unichar c);

void consumeComment(const NaiveCSSParser *myself, unichar c);
BOOL checkCommentState(const NaiveCSSParser *myself, unichar c);
void addCSSRuleWithPropertyNameOnly (const NaiveCSSParser *myself);
BOOL isSpace(unichar c);

#pragma mark State Machine Functions
void collectSelector(const NaiveCSSParser *myself, unichar c) {
    if (!isSpace(c)) {
        if(checkCommentState(myself, c))
            return;
        
        __unsafe_unretained NSMutableString *se = myself->_selector;
        
        if (c == '{') {
            // delete last empty space if there's one
            if (isSpace([se characterAtIndex:se.length - 1])) {
                [se deleteCharactersInRange:NSMakeRange(se.length - 1, 1)];
            }
            myself->_ruleSet = [[NSMutableSet alloc] init];
            
            myself->_prevChar = 0;
            myself->_state = STATE_PROPERTY_NAME;
        } else {
            if (isSpace(myself->_prevChar) && se.length > 0 && !isSpace([se characterAtIndex:se.length - 1])) {
                [se appendFormat:@"%c", ' '];    
            }
            [se appendFormat:@"%c", c];
        }
    }
    
    myself->_prevChar = c;
}

void addCSSRuleWithPropertyNameOnly (const NaiveCSSParser *myself) {
    __unsafe_unretained NSMutableString *pn = myself->_propertyName;
    if (pn.length > 0) {
            // delete last space if there's one
        if (isSpace([pn characterAtIndex:pn.length - 1])) {
            [pn deleteCharactersInRange:NSMakeRange(pn.length - 1, 1)];
        }
            // a CSS rule can contain only the property name
        [myself->_ruleSet addObject:[[CSSRule alloc] initWithPropertyName:pn propertyValue:nil]];
        [pn deleteCharactersInRange:NSMakeRange(0, pn.length)];
    }
}

void collectPropertyName(const NaiveCSSParser *myself, unichar c, const NSMutableDictionary *dict) {
    if (!isSpace(c)) {
        if(checkCommentState(myself, c))
            return;
        
        __unsafe_unretained NSMutableString *pn = myself->_propertyName;
        
        switch (c) {
            case ':':
                myself->_state = STATE_PROPERTY_VALUE;
                break;
            case ';':
            {
                addCSSRuleWithPropertyNameOnly(myself);
                myself->_state = STATE_PROPERTY_NAME;
                break;
            }
            case '}':
                addCSSRuleWithPropertyNameOnly(myself);
                myself->_state = STATE_SELECTOR;
                
                // save the rule set in the dictionary
                __unsafe_unretained NSMutableString *se = myself->_selector;
                [dict setObject:myself->_ruleSet forKey:se];
                [se deleteCharactersInRange:NSMakeRange(0, se.length)];
                break;
            default:
                [pn appendFormat:@"%c", c];
                break;
        }
    }
    myself->_prevChar = c;
}

void collectPropertyValue(const NaiveCSSParser *myself, unichar c) {
    if (!isSpace(c)) {
        if(checkCommentState(myself, c))
            return;
        
        __unsafe_unretained NSMutableString *pn = myself->_propertyName;
        __unsafe_unretained NSMutableString *pv = myself->_propertyValue;
        if (c == ';') {
            // delete last space if there's one
            if (isSpace([pn characterAtIndex:pn.length - 1])) {
                [pn deleteCharactersInRange:NSMakeRange(pn.length - 1, 1)];
            }
            if (isSpace([pv characterAtIndex:pv.length - 1])) {
                [pv deleteCharactersInRange:NSMakeRange(pv.length - 1, 1)];
            }
            
            [myself->_ruleSet addObject:[[CSSRule alloc] initWithPropertyName:pn propertyValue:pv]];
            
            [pn deleteCharactersInRange:NSMakeRange(0, pn.length)];
            [pv deleteCharactersInRange:NSMakeRange(0, pv.length)];
            myself->_state = STATE_PROPERTY_NAME;            
        } else {
            switch (c) {
                case '\'':
                    myself->_state = STATE_INSIDE_SINGLE_QUOTES;    
                    break;
                case '"':
                    myself->_state = STATE_INSIDE_DOUBLE_QUOTES;    
                    break;
                case '(':
                    myself->_state = STATE_INSIDE_BRACES;
                    break;
                default:
                    if (isSpace(myself->_prevChar) && pv.length > 0 && !isSpace([pv characterAtIndex:pv.length - 1])) {
                        [pv appendFormat:@"%c", ' '];    
                    }
                    [pv appendFormat:@"%c", c];
                    break;
            }
        }
    }
    
    myself->_prevChar = c;
}

void collectTextInsideQuotes(const NaiveCSSParser *myself, unichar c) {
    __unsafe_unretained NSMutableString *qs = myself->_quotedString;
    if ((c == '\'' && myself->_state == STATE_INSIDE_SINGLE_QUOTES)
        || (c == '"' && myself->_state == STATE_INSIDE_DOUBLE_QUOTES)
        || (c == ')' && myself->_state == STATE_INSIDE_BRACES)) {
        if (qs.length > 0) {
            switch (myself->_state) {
                case STATE_INSIDE_SINGLE_QUOTES:
                    [myself->_propertyValue appendFormat:@"'%@'", qs];
                    break;
                case STATE_INSIDE_DOUBLE_QUOTES:
                    [myself->_propertyValue appendFormat:@"\"%@\"", qs];
                    break;
                case STATE_INSIDE_BRACES:
                    [myself->_propertyValue appendFormat:@"(%@)", qs];
                    break;
            }
            
            [qs deleteCharactersInRange:NSMakeRange(0, qs.length)];
            myself->_state = STATE_PROPERTY_VALUE;
        }
    } else {
        [qs appendFormat:@"%c", c];
    }
}

void consumeComment(const NaiveCSSParser *myself, unichar c) {
    if (myself->_prevChar == '*' && c == '/') {
        myself->_state = myself->_prevState;
        myself->_prevChar = 0;
    } else {
        myself->_prevChar = c;
    }
}

BOOL checkCommentState(const NaiveCSSParser *myself, unichar c) {
    if (myself->_prevChar == '/' && c == '*') {
        switch (myself->_state) {
            case STATE_SELECTOR:
                // remove the last mistakenly appended character(a slash), which is part of the comment
                [myself->_selector deleteCharactersInRange:NSMakeRange(myself->_selector.length - 1, 1)];
                break;
            case STATE_PROPERTY_NAME:
                // remove the last mistakenly appended character(a slash), which is part of the comment
                [myself->_propertyName deleteCharactersInRange:NSMakeRange(myself->_propertyName.length - 1, 1)];
                break;
            case STATE_PROPERTY_VALUE:
                // remove the last mistakenly appended character(a slash), which is part of the comment
                [myself->_propertyValue deleteCharactersInRange:NSMakeRange(myself->_propertyValue.length - 1, 1)];
                break;
        }
        
        myself->_prevState = myself->_state;
        myself->_state = STATE_COMMENT;
        myself->_prevChar = 0;
        
        return YES;
    }
    return NO;
}

#pragma mark Assistant Functions
BOOL isSpace(unichar c) {
    return (c == ' ' || c == '\n' || c == '\t' || c == '\r');
}


#pragma mark Objective-C methods
-(id)init {
    self = [super init];
    if (self) {
        [self resetState];
    }
    return self;
}

-(void)resetState {
    _selector = [[NSMutableString alloc] init];
    _propertyName = [[NSMutableString alloc] init];
    _propertyValue = [[NSMutableString alloc] init];
    _quotedString = [[NSMutableString alloc] init];
    _state = STATE_SELECTOR;
    _prevChar = 0;
}

-(NSDictionary *) parse:(NSString *)cssStr {
    NSUInteger len = cssStr.length;
    if (cssStr && len == 0) {
        return nil;
    }
    
    NSMutableDictionary *cssRulesDict = [[NSMutableDictionary alloc] init];

    for (NSUInteger i = 0; i < len; ++i) {
        unichar c = [cssStr characterAtIndex:i];
        switch (_state) {
            case STATE_SELECTOR:
                collectSelector(self, c);
                break;
            case STATE_PROPERTY_NAME:
                collectPropertyName(self, c, cssRulesDict);
                break;    
            case STATE_PROPERTY_VALUE:
                collectPropertyValue(self, c);
                break;
            case STATE_INSIDE_SINGLE_QUOTES:
            case STATE_INSIDE_DOUBLE_QUOTES:
            case STATE_INSIDE_BRACES:
                collectTextInsideQuotes(self, c);
                break;
            case STATE_COMMENT:
                consumeComment(self, c);
                break;
        }
    }
    
    return cssRulesDict;
}

@end