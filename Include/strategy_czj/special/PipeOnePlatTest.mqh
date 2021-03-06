//+------------------------------------------------------------------+
//|                                              PipeOnePlatTest.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "PipeBase.mqh"
监控给定货币对的



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPipeOnePlatTest : public CPipeBase
  {
public:
                     CPipeOnePlatTest(void);
                    ~CPipeOnePlatTest(void);
protected:
   virtual bool              SendTick(); // 请求发送tick事件处理
   virtual bool              OpenPosition();   // 请求开仓事件处理 
   virtual bool              ClosePosition();  // 请求平仓事件处理
  };
//+------------------------------------------------------------------+
