//+------------------------------------------------------------------
//|                                                  CNamedPipes.mqh |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
//+------------------------------------------------------------------
//| 定义                                                          |
//+------------------------------------------------------------------

enum ENUM_PIPE_ACCESS
  {
   PIPE_ACCESS_INBOUND=1,
   PIPE_ACCESS_OUTBOUND=2,
   PIPE_ACCESS_DUPLEX=3,
  };
//+------------------------------------------------------------------
//|                                                                  |
//+------------------------------------------------------------------
enum ENUM_PIPE_MODE
  {
   PIPE_TYPE_RW_BYTE=0,
   PIPE_TYPE_READ_MESSAGE=2,
   PIPE_TYPE_WRITE_MESSAGE=4,
  };

#define PIPE_WAIT 0
#define PIPE_NOWAIT 1

#define ERROR_PIPE_CONNECTED 535
#define ERROR_BROKEN_PIPE 109

#define INVALID_HANDLE_VALUE -1
#define GENERIC_READ  0x80000000
#define GENERIC_WRITE  0x40000000
#define OPEN_EXISTING  3
#define PIPE_UNLIMITED_INSTANCES 255
#define MQLTICK_SIZE 40
#define PIPE_BUFFER_SIZE 4096
#define STR_SIZE 255

//+------------------------------------------------------------------
//| DLL imports                                                      |
//+------------------------------------------------------------------
#import "kernel32.dll"
int CreateNamedPipeW(string pipeName,int openMode,int pipeMode,int maxInstances,int outBufferSize,int inBufferSize,int defaultTimeOut,int security);
int WaitNamedPipeW(string lpNamedPipeName,int nTimeOut);
bool ConnectNamedPipe(int pipeHandle,int overlapped);
bool DisconnectNamedPipe(int pipeHandle);
int CreateFileW(string name,int desiredAccess,int SharedMode,int security,int creation,int flags,int templateFile);
int WriteFile(int fileHandle,short &buffer[],int bytes,int &numOfBytes,int overlapped);
int WriteFile(int fileHandle,char &buffer[],int bytes,int &numOfBytes,int overlapped);
int WriteFile(int fileHandle,MqlTick &outgoing,int bytes,int &numOfBytes,int overlapped);
int WriteFile(int fileHandle,int &var,int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,short &buffer[],int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,char &buffer[],int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,MqlTick &incoming,int bytes,int &numOfBytes,int overlapped);
int ReadFile(int fileHandle,int &incoming,int bytes,int &numOfBytes,int overlapped);
int CloseHandle(int fileHandle);
int GetLastError(void);
int FlushFileBuffers(int pipeHandle);
#import
//+------------------------------------------------------------------
//|                                                                  |
//+------------------------------------------------------------------
class CNamedPipe
  {
private:
   int               hPipe; // 管道句柄
   string            pipeNumber;
   string            pipeNamePrefix;
   int               BufferSize;

protected:

public:
                     CNamedPipe();
                    ~CNamedPipe();

   bool              Create(int account);
   bool              Connect();
   bool              Disconnect();
   bool              Open(int account);
   int               Close();
   void              Flush();
   int               WriteUnicode(string message);
   string            ReadUnicode();
   int               WriteANSI(string message);
   string            ReadANSI();
   bool              ReadTick();
   bool              WriteTick(MqlTick &outgoing);
   string            GetPipeName();

   MqlTick           incoming;
  };
//+------------------------------------------------------------------
//| CNamedPipe constructor
//+------------------------------------------------------------------
CNamedPipe::CNamedPipe(void)
  {
   pipeNamePrefix="\\\\.\\pipe\\";
   BufferSize=PIPE_BUFFER_SIZE;
   hPipe=INVALID_HANDLE_VALUE;
   int err=kernel32::GetLastError();
  }
//+------------------------------------------------------------------
//| CNamedPipe destructor
//+------------------------------------------------------------------
CNamedPipe::~CNamedPipe(void)
  {
   if(hPipe!=INVALID_HANDLE_VALUE)
      CloseHandle(hPipe);

  }
//+------------------------------------------------------------------
/// Create() : 尝试创建命名管道的实例
/// \参数 account - 源终端帐号  
/// \返回 true - 如果创建成功, false 否则 
//+------------------------------------------------------------------
bool CNamedPipe::Create(int account=0)
  {
   if(account==0)
      pipeNumber=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   else
      pipeNumber=IntegerToString(account);

   string fullPipeName=pipeNamePrefix+pipeNumber;

   hPipe=CreateNamedPipeW(fullPipeName,
                          (int)GENERIC_READ|GENERIC_WRITE|(ENUM_PIPE_ACCESS)PIPE_ACCESS_DUPLEX,
                          (ENUM_PIPE_MODE)PIPE_TYPE_RW_BYTE,PIPE_UNLIMITED_INSTANCES,
                          BufferSize*sizeof(ushort),BufferSize*sizeof(ushort),0,NULL);

   if(hPipe==INVALID_HANDLE_VALUE) return false;
   else
      return true;

  }
//+------------------------------------------------------------------
/// Connect() : 等待客户端连接管道               
/// \返回 true - 如果连接, false 否则.
//+------------------------------------------------------------------
bool CNamedPipe::Connect(void)
  {
   if(ConnectNamedPipe(hPipe,NULL)==false)
      return(kernel32::GetLastError()==ERROR_PIPE_CONNECTED);
   else return true;
  }
//+------------------------------------------------------------------
/// Disconnect(): 从通道断开
/// \返回 true - 如果断开, false 否则    
//+------------------------------------------------------------------
bool CNamedPipe::Disconnect(void)
  {
   return DisconnectNamedPipe(hPipe);
  }
//+------------------------------------------------------------------
/// Open() : 试图打开之前创建的管道
/// \参数 account - 源终端帐号
/// \返回 true - 如果成功, false 否则
//+------------------------------------------------------------------
bool CNamedPipe::Open(int account=0)
  {
   if(account==0)
      pipeNumber=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   else
      pipeNumber=IntegerToString(account);

   string fullPipeName=pipeNamePrefix+pipeNumber;

   if(hPipe==INVALID_HANDLE_VALUE)
     {
      if(WaitNamedPipeW(fullPipeName,5000)==0)
        {
         Print("管道 "+fullPipeName+" 忙.");
         return false;
        }

      hPipe=CreateFileW(fullPipeName,(int)GENERIC_READ|GENERIC_WRITE,0,NULL,OPEN_EXISTING,0,NULL);
      if(hPipe==INVALID_HANDLE_VALUE)
        {
         Print("管道打开失败");
         return false;
        }

     }
   return true;
  }
//+------------------------------------------------------------------
/// Close() : 关闭管道句柄
/// \返回 0 如果成功, 非-0 否则  
//+------------------------------------------------------------------
int CNamedPipe::Close(void)
  {
   return CloseHandle(hPipe);
  }
  
//+------------------------------------------------------------------
/// WriteUnicode() : 写 Unicode 字符串至管道
/// \参数 message - 发送的字符串
/// \返回写入管道的字节数                                                                  |
//+------------------------------------------------------------------
int CNamedPipe::WriteUnicode(string message)
  {
   int ushortsToWrite, bytesWritten;
   ushort UNICODEarray[];
   ushortsToWrite = StringToShortArray(message, UNICODEarray);
   WriteFile(hPipe,ushortsToWrite,sizeof(int),bytesWritten,0);
   WriteFile(hPipe,UNICODEarray,ushortsToWrite*sizeof(ushort),bytesWritten,0);
   return bytesWritten;
  }
//+------------------------------------------------------------------
/// ReadUnicode(): 从管道读 Unicode 字符串
/// \返回 Unicode 字符串 (MQL5 字符串)
//+------------------------------------------------------------------
string CNamedPipe::ReadUnicode(void)
  {
   string ret;
   ushort UNICODEarray[STR_SIZE*sizeof(uint)];
   int bytesRead, ushortsToRead;
 
   ReadFile(hPipe,ushortsToRead,sizeof(int),bytesRead,0);
   ReadFile(hPipe,UNICODEarray,ushortsToRead*sizeof(ushort),bytesRead,0);
   if(bytesRead!=0)
      ret = ShortArrayToString(UNICODEarray);
   
   return ret;
  }
//+------------------------------------------------------------------
/// WriteANSI() : 写 ANSI 字符串至管道
/// \参数 message - 发送的字符串
/// \返回写入管道的字节数                                                                  |
//+------------------------------------------------------------------
int CNamedPipe::WriteANSI(string message)
  {
   int bytesToWrite, bytesWritten;
   uchar ANSIarray[];
   bytesToWrite = StringToCharArray(message, ANSIarray);
   WriteFile(hPipe,bytesToWrite,sizeof(int),bytesWritten,0);
   WriteFile(hPipe,ANSIarray,bytesToWrite,bytesWritten,0);
   return bytesWritten;
  }
//+------------------------------------------------------------------
/// ReadANSI(): 从管道读 ANSI 字符串
/// \返回 Unicode 字符串 (MQL5 字符串)
//+------------------------------------------------------------------
string CNamedPipe::ReadANSI(void)
  {
   string ret;
   uchar ANSIarray[STR_SIZE];
   int bytesRead, bytesToRead;
 
   ReadFile(hPipe,bytesToRead,sizeof(int),bytesRead,0);
   ReadFile(hPipe,ANSIarray,bytesToRead,bytesRead,0);
   if(bytesRead!=0)
      ret = CharArrayToString(ANSIarray);
   
   return ret;
  }
//+------------------------------------------------------------------
/// WriteTick() : 写 MqlTick 至管道
/// \参数 outgoing - 发送的 MqlTick
/// \返回 true 如果即时价写成功, false 否则
//+------------------------------------------------------------------
bool CNamedPipe::WriteTick(MqlTick &outgoing)
  {
   int bytesWritten;

   WriteFile(hPipe,outgoing,MQLTICK_SIZE,bytesWritten,0);

   return(bytesWritten==MQLTICK_SIZE);
  }
//+------------------------------------------------------------------
/// ReadTick() : 从管道读 MqlTick
/// \返回 true 如果即时价读成功, false 否则
//+------------------------------------------------------------------
bool CNamedPipe::ReadTick()
  {
   int bytesRead;

   ReadFile(hPipe,incoming,MQLTICK_SIZE,bytesRead,NULL);

   return(bytesRead==MQLTICK_SIZE);
  }
//+------------------------------------------------------------------

//+------------------------------------------------------------------
/// GetPipeName() : 返回管道名称
/// \返回包含管道名称的字符串
//+------------------------------------------------------------------
string CNamedPipe::GetPipeName(void)
  {
   return pipeNumber;
  }
//+------------------------------------------------------------------
/// Flush() : 刷管道缓存区
//+------------------------------------------------------------------
void CNamedPipe::Flush(void)
  {
   FlushFileBuffers(hPipe);
  }
//+------------------------------------------------------------------
