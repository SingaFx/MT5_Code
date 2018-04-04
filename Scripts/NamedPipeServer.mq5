//+------------------------------------------------------------------
//|                                              NamedPipeServer.mq5 |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"

#include <CNamedPipes.mqh>

CNamedPipe pipe;
//+------------------------------------------------------------------+
//| 交易程序初始函数                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
   bool tickReceived;
   int i=0;

   if(pipe.Create()==true)
      while (GlobalVariableCheck("gvar0")==false)
        {
         Print("等待客户端连接.");
         if (pipe.Connect()==true)
            Print("管道已连接");
         while(true)
           {
            do
              {
               tickReceived=pipe.ReadTick();

               if(tickReceived==false)
                 {
                  if(GetLastError()==ERROR_BROKEN_PIPE)
                    {
                     Print("客户端从管道断开 "+pipe.GetPipeName());
                     pipe.Disconnect();
                     break;
                    }
                 } else i++;
                  Print(IntegerToString(i) + "即时价收到.");
              } while(tickReceived==true);
            if (i>0) 
            {
               Print(IntegerToString(i) + "即时价收到.");
               i=0;
            };
            if(GlobalVariableCheck("gvar0")==true || (GetLastError()==ERROR_BROKEN_PIPE)) break;
           }

        }

 pipe.Close(); 
  }