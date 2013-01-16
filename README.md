This library implements a naive CSS parser that parses a string of CSS rules into a key-value map.
Example
======
Simply feed the parser a CSS string, the parser runs and returns an **NSDictionary**.

    NSString *cssString = ...;
    NaiveCSSParser *cssParser = [[NaiveCSSParser alloc] init];
    NSDictionary *dict = [cssParser parse:cssString];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableSet *set, BOOL *stop) {
        [set enumerateObjectsUsingBlock:^(CSSRule *rule, BOOL *stop) {
            NSLog(@" {%@:%@}", rule.propertyName, rule.propertyValue);
        }]; 
    }]; 

License
=======
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. 
