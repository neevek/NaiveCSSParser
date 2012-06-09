//
//  CSSRule.h
//  NaiveCSSParser
//
//  Created by neevek on 12-6-9.
//  Copyright (c) 2012 neevek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSRule : NSObject
@property (strong, nonatomic) NSString *propertyName;
/* propertyValue may be nil, because this is allowed in CSS*/
@property (strong, nonatomic) NSString *propertyValue;

-(id) initWithPropertyName:(NSString *)name propertyValue:(NSString *)value;
@end
