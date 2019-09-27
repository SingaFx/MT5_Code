//+------------------------------------------------------------------+
//|                                          Demo_FileWiteStruct.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| 脚本程序启动函数                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
   double data[5][2];
   for(int i=0;i<5;i++)
     {
      for(int j=0;j<2;j++)
        {
         data[i][j]=rand();
        }
     }
   
   for(int i=0;i<5;i++)
     {
      Print(i,"no sort ",data[i][0]," ",data[i][1]);
     }
   ArraySort(data);
   for(int i=0;i<5;i++)
     {
      Print(i,"sort ",data[i][0]," ",data[i][1]);
     }

  }
//+------------------------------------------------------------------+
