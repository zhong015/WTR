//
//  WTRMultipartForm.m
//  ZJY
//
//  Created by wfz on 2017/4/28.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRMultipartForm.h"

@implementation OnePartForm

+(OnePartForm *)FormWithName:(NSString *)name string:(NSString *)string
{
    return [self FormWithName:name filename:nil mimeType:nil data:[string dataUsingEncoding:NSUTF8StringEncoding]];
}
+(OnePartForm *)FormWithName:(NSString *)name data:(NSData *)data
{
    return [self FormWithName:name filename:nil mimeType:nil data:data];
}
+(OnePartForm *)FormWithName:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data
{
    OnePartForm *onePart=[[OnePartForm alloc]init];
    onePart.name=name;
    onePart.filename=filename;
    onePart.mimeType=mimeType;
    onePart.data=data;
    return onePart;
}

@end

@implementation WTRMultipartForm


+(NSMutableURLRequest *)urlRequestWithUrlStr:(NSString *)urlStr partList:(NSArray <OnePartForm *>*)partArray
{
    NSMutableURLRequest *mureq=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [mureq setHTTPMethod:@"POST"];
    
    NSString *boundary=[NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    
    [mureq setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSData *bodyData=[self GetHttpBodyWithPartList:partArray boundary:boundary];
    [mureq setHTTPBody:bodyData];
    
    [mureq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length] forHTTPHeaderField:@"Content-Length"];
    
    return mureq;
}
+(NSData *)GetHttpBodyWithPartList:(NSArray <OnePartForm *>*)partArray boundary:(NSString *)boundary
{
    NSMutableData *mudata=[[NSMutableData alloc] init];
   
    for (int i=0;i<partArray.count;i++) {
        
        OnePartForm *oneForm=[partArray objectAtIndex:i];
        
        [mudata appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (oneForm.filename) {
            [mudata appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",oneForm.name,oneForm.filename] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
            [mudata appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",oneForm.name] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (oneForm.mimeType) {
            [mudata appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n",oneForm.mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [mudata appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [mudata appendData:oneForm.data];
        
        if (i==partArray.count-1) {
            [mudata appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
            [mudata appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return mudata;
}



@end
