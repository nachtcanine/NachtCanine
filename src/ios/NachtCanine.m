		//
//  CountAdd.m
//  CountDemo
//
//  Created by System Administrator on 16/10/25.
//
//

#import "NachtCanine.h"
#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>

/*定义socket�?��?对象*/
@interface SocketConnection : NSObject
{
    NSString * Port;
    NSString * Host;
    int clientSocketId;
    BOOL success;
    struct sockaddr_in addr;
    struct sockaddr_in peerAddr;
}

-(void) setHost:(NSString *)host;
-(void) setPort:(NSString *)port;
-(NSString *) getIdString;
-(void) openConnection;
-(void) sendHexString:(NSString *)info;
//-(NSData*)stringToByte:(NSString*)info;

@end

@implementation SocketConnection

-(void) setHost:(NSString *)host{
    Host=host;
}

-(void) setPort:(NSString *)port{
    Port=port;
}

-(NSString *) getIdString{
    NSString * resultString;
    resultString=[Host stringByAppendingString:Port];
    return resultString;
}

-(void) openConnection{
    // 第一步：创建soket
    // TCP是基于数�?��?的，因此�?�数二使用SOCK_STREAM
    int error = -1;
    clientSocketId = socket(AF_INET, SOCK_STREAM, 0);
    success = (clientSocketId != -1);
    
    // 第二步：绑定端�?��?�
    if (success) {
        NSLog(@"client socket create success");
        // �?始化
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        
        // 指定�??议簇为AF_INET，比如TCP/UDP等
        addr.sin_family = AF_INET;
        
        // 监�?�任何ip地�?�
        addr.sin_addr.s_addr = INADDR_ANY;
        error = bind(clientSocketId, (const struct sockaddr *)&addr, sizeof(addr));
        success = (error == 0);
    }
    if (success) {
        // p2p
        
        memset(&peerAddr, 0, sizeof(peerAddr));
        peerAddr.sin_len = sizeof(peerAddr);
        peerAddr.sin_family = AF_INET;
        int intPort = [Port intValue];
        peerAddr.sin_port = htons(intPort);
        
        // 指定�?务端的ip地�?�，测试时，修改�?对应自己�?务器的ip
        peerAddr.sin_addr.s_addr = inet_addr([Host UTF8String]);
        
        socklen_t addrLen;
        addrLen = sizeof(peerAddr);
        NSLog(@"will be connecting");
        
        // 第三步：连接�?务器
        error = connect(clientSocketId, (struct sockaddr *)&peerAddr, addrLen);
        success = (error == 0);
        
        if (success) {
            // 第四步：获�?�套接字信�?�
            error = getsockname(clientSocketId, (struct sockaddr *)&addr, &addrLen);
            success = (error == 0);
        } else {
            close(clientSocketId);
            @throw [NSException exceptionWithName:@"Singleton" reason:@"无法连接�?务器" userInfo:nil];
        }
    }
}

-(void) sendHexString:(NSString *)info{
    @try
    {
        int optval, optlen = sizeof(int);
        getsockopt(clientSocketId, SOL_SOCKET, SO_ERROR,(char*) &optval, &optlen);
        if(optval!=0)
        {
            //�?�?�?�导致socket关闭，�?新连接。
            [self openConnection];
            //socklen_t addrLen;
            //addrLen = sizeof(peerAddr);
            //int error = connect(clientSocketId, (struct sockaddr *)&peerAddr, addrLen);
            //success = (error == 0);
            //if (success)
            //{
            //    error = getsockname(clientSocketId, (struct sockaddr *)&addr, &addrLen);
            //    success = (error == 0);
           // } else
            //{
             //   close(clientSocketId);
             //   @throw [NSException exceptionWithName:@"Singleton" reason:@"无法连接�?务器" userInfo:nil];
            //}
        }
        //else
        //{
            NSData * bytes=[self stringToByte:info];
            send(clientSocketId, [bytes bytes], [bytes length], 0);
        //}
    }
    @catch (NSException *exception)
    {
        @throw [NSException exceptionWithName:@"Singleton" reason:@"无法连接�?务器" userInfo:nil];
    }
}

-(NSData*)stringToByte:(NSString*)info{
    NSString *hexString=[[info uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两�?16进制数中的第一�?(高�?*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两�?16进制数中的第二�?(低�?)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化�?�的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

@end



static NSMutableArray * socketArray;

@implementation NachtCanine

- (void)sendInfo:(CDVInvokedUrlCommand *)command
{
    NSString *callBackId=command.callbackId;
    CDVPluginResult *result=nil;
    @try
    {
        NSString *host = [command.arguments objectAtIndex:0];
        NSString *port = [command.arguments objectAtIndex:1];
        NSString *message = [command.arguments objectAtIndex:2];
        
        if(socketArray==nil){
            socketArray=[[NSMutableArray alloc] init];
        }
        SocketConnection * socketConnection=nil;
        NSString * matchIdString=[host stringByAppendingString:port];
        for (int i = 0; i < socketArray.count; i++)
        {
            SocketConnection *innerSocket= [socketArray objectAtIndex:i];
            NSString *innerIdString=[innerSocket getIdString];
            if([matchIdString isEqualToString:innerIdString]){
                socketConnection=innerSocket;
                break;
            }
        }
        if(socketConnection==nil){
            socketConnection=[[SocketConnection alloc] init];
            [socketConnection setHost:host];
            [socketConnection setPort:port];
            [socketConnection openConnection];
            [socketArray addObject:socketConnection];
        }
        
        NSArray *messages=[message componentsSeparatedByString:@";"];
        double nextTime=0;
        for (id info in messages)
        {
            if(![info isEqual:nil] && ![info isEqual:@""])
            {
                NSArray * infos=[info componentsSeparatedByString:@"@"];
                [NSThread sleepForTimeInterval:nextTime];
                [socketConnection sendHexString:[infos objectAtIndex:0]];
                //[self Send:host :port :[infos objectAtIndex:0]];
                if([infos count]==2)
                {
                    nextTime = [[infos objectAtIndex:1] doubleValue];
                }
            }
        }
        result=[CDVPluginResult resultWithStatus:(CDVCommandStatus_OK)];
    }
    @catch (NSException *e)
    {
        result=[CDVPluginResult resultWithStatus:(CDVCommandStatus_ERROR) messageAsString:[e reason]];
    }
    @finally
    {
        [self.commandDelegate sendPluginResult:result callbackId:callBackId];
    }
}

@end




















