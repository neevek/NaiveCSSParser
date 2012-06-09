//
//  CSSRule.m
//  NaiveCSSParser
//
//  Created by neevek on 12-6-9.
//  Copyright (c) 2012 neevek. All rights reserved.
//

#import "CSSRule.h"

@implementation CSSRule
@synthesize propertyName = _propertyName;
@synthesize propertyValue = _propertyValue;

-(id)initWithPropertyName:(NSString *)name propertyValue:(NSString *)value {
    self = [super init];
    if (self) {
        _propertyName = [name copy];
        _propertyValue = [value copy];
    }
    return self;
}

-(BOOL)isEqual:(CSSRule *)object {
    if (self == object || ([object.propertyName isEqualToString:self.propertyName] 
                        && [object.propertyValue isEqualToString:self.propertyValue])) {
        return YES;
    }
    return NO;
}
@end
