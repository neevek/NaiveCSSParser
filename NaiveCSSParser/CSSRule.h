/*
 *  Copyright (C) 2013 neevek(i@neevek.net)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#import <Foundation/Foundation.h>

@interface CSSRule : NSObject
@property (strong, nonatomic) NSString *propertyName;
/* propertyValue may be nil, because this is allowed in CSS*/
@property (strong, nonatomic) NSString *propertyValue;

-(id) initWithPropertyName:(NSString *)name propertyValue:(NSString *)value;
@end
