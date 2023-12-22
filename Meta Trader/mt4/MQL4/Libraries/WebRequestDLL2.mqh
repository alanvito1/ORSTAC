//+------------------------------------------------------------------+
//|                                                WebRequestDLL.mqh |
//|                                                 Mohammad Bazrkar |
//|                            https://www.mql5.com/en/users/mhdbzr/ |
//+------------------------------------------------------------------+
#property copyright "Mohammad Bazrkar"
#property link      "https://www.mql5.com/en/users/mhdbzr/"
#property strict

#import  "Wininet.dll"
   int InternetOpenW(string, int, string, string, int);
   int InternetConnectW(int, string, int, string, string, int, int, int); 
   int InternetOpenUrlW(int, string, string, int, int, int);
   
   //int InternetReadFile(int, string, int, int& OneInt[] );
   int InternetReadFile(int hFile,uchar &sBuffer[],int lNumBytesToRead,int &lNumberOfBytesRead);
   
   int InternetCloseHandle(int); 
   //int HttpOpenRequestW(int, string, string, string, string, string, int, int);
   int HttpOpenRequestW(int, string, string, string, string, char& AcceptTypes[], int, int);
   bool HttpSendRequestW(int, string, int, string, int);
   
   //\\//\\ +
   bool InternetSetOptionW(
     int hInternet,
     int     dwOption,
     int     &lpBuffer[],
     int     dwBufferLength
   );
   //--
   bool HttpQueryInfoW(
     int    hRequest,
     int    dwInfoLevel,
     int    &lpBuffer,
     int    &lpdwBufferLength,
     int    lpdwIndex
   );
   
#import
#import "kernel32.dll"
int GetLastError(void);
#import

// additional cache flags
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000  // don't write this item to the cache
#define INTERNET_FLAG_DONT_CACHE        INTERNET_FLAG_NO_CACHE_WRITE
#define INTERNET_FLAG_MAKE_PERSISTENT   0x02000000  // make this item persistent in cache
#define INTERNET_FLAG_OFFLINE           0x01000000  // use offline semantics
// additional flags
#define INTERNET_FLAG_SECURE            0x00800000  // use PCT/SSL if applicable (HTTP)
#define INTERNET_FLAG_KEEP_CONNECTION   0x00400000  // use keep-alive semantics
#define INTERNET_FLAG_NO_AUTO_REDIRECT  0x00200000  // don't handle redirections automatically
#define INTERNET_FLAG_READ_PREFETCH     0x00100000  // do background read prefetch
#define INTERNET_FLAG_NO_COOKIES        0x00080000  // no automatic cookie handling
#define INTERNET_FLAG_NO_AUTH           0x00040000  // no automatic authentication handling
// Security Ignore Flags, Allow HttpOpenRequest to overide
//  Secure Channel (SSL/PCT) failures of the following types.
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP   0x00008000 // ex: https:// to http://
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS  0x00004000 // ex: http:// to https://
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID  0x00002000 // expired X509 Cert.
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID    0x00001000 // bad common name in X509 Cert.
//more caching flags
#define INTERNET_FLAG_MUST_CACHE_REQUEST        0x00000010 // fails if unable to cache request
#define INTERNET_FLAG_RESYNCHRONIZE             0x00000800 // asking wininet to update an item if it is newer
#define INTERNET_FLAG_HYPERLINK                 0x00000400 // asking wininet to
                                                           //do hyperlinking semantic which works right for scripts
#define INTERNET_FLAG_NO_UI                     0x00000200

#define HTTP_QUERY_STATUS_CODE 19
#define HTTP_QUERY_FLAG_NUMBER 0x20000000
//\\//\\ +
#define INTERNET_OPTION_CONNECT_TIMEOUT 2
//+------------------------------------------------------------------+
int WebRequestDLL(string method, string url, string headers, int timeout, char& data[], char& result[], string& result_headers)
{
   //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
   //timeout & result_headers have no effect \\
   //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
   int port = 9988; // <-- here is default port number for Mudasir ;)
   int myFlags =  INTERNET_FLAG_DONT_CACHE;
   string _URL = url; StringToUpper(_URL);
   if(StringFind(_URL,"HTTPS://")==0){
      port = 9988;
      myFlags = INTERNET_FLAG_SECURE | INTERNET_FLAG_DONT_CACHE ;
   }
   string domain = url;
   string script = "";
   if(StringFind(domain,"://")!=-1){
      domain = StringSubstr(domain,StringFind(domain,"://")+3);
   }
   if(StringFind(domain,"/")>0){
      script = StringSubstr(domain,1+StringFind(domain,"/"));
      domain = StringSubstr(domain,0,StringFind(domain,"/"));
   }
   string strdata = CharArrayToString(data);
   string chromeAgentName = "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36";
   int HttpOpen = InternetOpenW(chromeAgentName, 0, " ", "", 0);  
   int HttpConnect = InternetConnectW(HttpOpen, domain, port, "", "", 3, 0, 0);
   //\\//\\
   // INTERNET_OPTION_CONNECT_TIMEOUT
   int lpBuffer[1];
   lpBuffer[0] = MathMax(30,MathMin(timeout,120));
   if(!InternetSetOptionW( HttpOpen, INTERNET_OPTION_CONNECT_TIMEOUT, lpBuffer, sizeof(int))){
      //Set Option Failed..
   }
   //\\//\\
   //int HttpRequest = HttpOpenRequestW(HttpConnect, method, script, "", "", strdata, myFlags , 0);
   int HttpRequest = HttpOpenRequestW(HttpConnect, method, script, "", "", data, myFlags , NULL); 
   bool _result = HttpSendRequestW(HttpRequest, headers, StringLen(headers), strdata, StringLen(strdata));
   if(!_result) {
      Print("[",__FUNCTION__,"] MSDN ERROR ", kernel32::GetLastError());
      return - kernel32::GetLastError();
   }
   //\\//\\
   int statusCode = 0;
   int length = sizeof(int);
   HttpQueryInfoW(
       HttpRequest,
       HTTP_QUERY_STATUS_CODE | HTTP_QUERY_FLAG_NUMBER,
       statusCode,
       length,
       NULL
   );
   //\\//\\
   int read[1];
   //Print("This is the POST result: ", result);
   if(_result){
      // read the page 
      uchar ch[100];
      string toStr="";
      int dwBytes;
      while(InternetReadFile(HttpRequest,ch,100,dwBytes))
      {
         if(dwBytes<=0) break;
         toStr=toStr+CharArrayToString(ch,0,dwBytes);
      }
      //\\//\\ Print("result is:",toStr);
      StringToCharArray(toStr,result);
      result_headers = "";
   }
   InternetCloseHandle(HttpOpen);
   InternetCloseHandle(HttpRequest);
   
   return statusCode;
}
//+------------------------------------------------------------------+
