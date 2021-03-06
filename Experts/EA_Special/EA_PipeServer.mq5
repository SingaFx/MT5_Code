//+------------------------------------------------------------------+
//|                                                EA_PipeServer.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <CNamedPipes.mqh>

CNamedPipe pipe;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   bool tickReceived;
   int i=0;
   if(pipe.Create(50231716)==true)
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
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
