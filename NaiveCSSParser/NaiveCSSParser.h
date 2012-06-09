//
//  NaiveCSSParser.h
//  NaiveCSSParser
//
//  Created by neevek on 12-6-9.
//  Copyright (c) 2012 neevek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NaiveCSSParser : NSObject

-(void)resetState;
-(NSDictionary *) parse:(NSString *)cssStr;

@end
