//+------------------------------------------------------------------+
//|                                                     PipeBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Files\FilePipe.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|            品种数组(管道通过index-id来通信)                      |
//+------------------------------------------------------------------+
string SYMBOLS_ARRAY[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
//+------------------------------------------------------------------+
//|               监控事件的枚举类型                                 |
//+------------------------------------------------------------------+
enum MonitorEventType
  {
   ENUM_MONITOR_EVENT_SEND_TICK=1,// 请求发送tick事件
   ENUM_MONITOR_EVENT_OPEN_POSITION=2,// 请求开仓事件
   ENUM_MONITOR_EVENT_CLOSE_POSITION=3 // 请求平仓事件
  };
//+------------------------------------------------------------------+
//|            开仓结果的数据结构                                    |
//+------------------------------------------------------------------+
struct OpenPositionResult
  {
   double            open_price;
   long              position_id;
   void              Init(double price,long id);
  };
//+------------------------------------------------------------------+
//|       结构体初始化方法                                           |
//+------------------------------------------------------------------+
void OpenPositionResult::Init(double price,long id)
  {
   open_price=price;
   position_id=id;
  }
enum HandleState
  {
   ENUM_HANDLE_STATE_CONNECTION_LOSS=1, // 连接失败状态
   ENUM_HANDLE_STATE_GET_TICK_FAILED=2,  // 获取tick失败
   ENUM_HANDLE_STATE_OPEN_FAILED=3,   // 开仓失败状态
   ENUM_HANDLE_STATE_CLOSE_FAILED=4,  // 平仓失败状态
   ENUM_HANDLE_STATE_SUCCESS=5   // 处理成功(正常)
  };
//+------------------------------------------------------------------+
//|             管道客户端监听服务器的处理操作类                     |
//+------------------------------------------------------------------+
class CPipeBase
  {
private:
   CFilePipe         PipeManager;   // 命名管道处理器
   CTrade            trade;   // 进行EA交易相关操作
   MonitorEventType  m_event; // 记录监听到的事件
   MqlTick           symbol_tick;   // 品种tick数据
   ENUM_ORDER_TYPE   order_type;    // 开仓订单类型
   double            symbol_lots;   // 开仓手数
   int               comment;       // 开仓comment
   int               symbol_index;   // 开仓品种索引
   OpenPositionResult result_open;   // 开仓结果的数据结构
   long              request_close; // 平仓请求的仓位id
   HandleState       handle_state; // 记录事件是否成功处理
public:
                     CPipeBase(void){};
                    ~CPipeBase(void){};
   bool              ConnectedToServer(string pipe_name); // 同服务器管道建立连接
   void              EventHandle(); // 监听事件并进行对应处理
protected:
   virtual bool      SendTick(); //    请求发送tick事件处理
   virtual bool      OpenPosition();   // 请求开仓事件处理 
   virtual bool      ClosePosition();  // 请求平仓事件处理
private:
   void              RecordConnectionLoss(string infor_print); // 记录网络丢失的情况
   void              RecordOpenFailed(string infor_print); // 记录开仓失败的情况
   void              RecordCloseFailed(string infor_print); // 记录平仓失败的情况
   void              RecordGetTickFailed(string infor_print);  // 记录获取tick失败的情况
   void              RecordSuccessInfor(string infor_print);   // 记录成功操作的信息
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPipeBase::ConnectedToServer(string pipe_name)
  {
   if(PipeManager.Open("\\\\REN\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeManager.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("管道连接成功:",pipe_name);
      return true;
     }
   if(PipeManager.Open("\\\\.\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeManager.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("管道连接成功:",pipe_name);
      return true;
     }
   Print("管道连接失败！");
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeBase::EventHandle(void)
  {
   if(!PipeManager.ReadInteger(m_event)) // 从管道读取监听事件的代码
     {
      Print("Pipe 连接失败: 读取监听事件失败！");
      return;
     }
   switch(m_event)
     {
      case ENUM_MONITOR_EVENT_SEND_TICK :
         if(!SendTick()) Print("监听事件处理失败:",EnumToString(m_event));
         //else    Print("监听事件处理成功:",EnumToString(m_event));
         break;
      case ENUM_MONITOR_EVENT_OPEN_POSITION:
         if(OpenPosition()) Print("监听事件处理成功:",EnumToString(m_event));
         else Print("监听事件处理失败:",EnumToString(m_event));
         break;
      case ENUM_MONITOR_EVENT_CLOSE_POSITION:
         if(ClosePosition())Print("监听事件处理成功:",EnumToString(m_event));
         else Print("监听事件处理失败:",EnumToString(m_event));
         break;
      default:
         Print("未知的监听事件:",m_event);
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPipeBase::SendTick(void)
  {
   // 读取品种的index
   if(!PipeManager.ReadInteger(symbol_index))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   // 拷贝Tick数据
   if(!SymbolInfoTick(SYMBOLS_ARRAY[symbol_index],symbol_tick))
     {
      RecordGetTickFailed(__FUNCTION__);
      if(!PipeManager.WriteInteger(false))
        {
         RecordConnectionLoss(__FUNCTION__);
         return false;
        }
     }
   else
     {
      if(!PipeManager.WriteInteger(true))
        {
         RecordConnectionLoss(__FUNCTION__);
         return false;
        }
     }
   // 发送tick数据
   if(!PipeManager.WriteStruct(symbol_tick))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   //RecordSuccessInfor("Tick 发送成功: size of "+string(sizeof(symbol_tick))+" ask/bid:"+DoubleToString(symbol_tick.ask,5)+"/"+DoubleToString(symbol_tick.bid));
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPipeBase::OpenPosition(void)
  {
   // 读取品种代码，订单类型，手数，comment
   if(!PipeManager.ReadInteger(symbol_index))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   if(!PipeManager.ReadInteger(order_type))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   if(!PipeManager.ReadDouble(symbol_lots))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   if(!PipeManager.ReadInteger(comment))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
     
   RecordSuccessInfor("成功读取开仓请求数据(symbol_index/order/lots/comment):"+string(symbol_index)+"/"+EnumToString(order_type)+"/"+DoubleToString(symbol_lots,2)+"/"+string(comment));
   // 进行交易并发送交易成功与否的结果
   if(!trade.PositionOpen(SYMBOLS_ARRAY[symbol_index],order_type,symbol_lots,0,0,0,string(comment)))
     {
      RecordOpenFailed(__FUNCTION__);
      if(!PipeManager.WriteInteger(false))
        {
         RecordConnectionLoss(__FUNCTION__);
         return false;
        }
     }
   else
     {
      RecordSuccessInfor("开仓成功："+__FUNCTION__);
      if(!PipeManager.WriteInteger(true))
        {
         RecordConnectionLoss(__FUNCTION__);
         return false;
        }
     }
   // 发送开仓结果
   result_open.Init(trade.ResultPrice(),trade.ResultOrder());
   if(!PipeManager.WriteStruct(result_open))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   RecordSuccessInfor("成功发送开仓结果！size of:"+string(sizeof(result_open))+" position_id:"+string(result_open.position_id)+" open_price:"+DoubleToString(result_open.open_price,5));  
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPipeBase::ClosePosition(void)
  {
  // 读取平仓的pos-id
   if(!PipeManager.ReadLong(request_close))
     {
      RecordConnectionLoss(__FUNCTION__);
      return false;
     }
   // 进行平仓操作(进行三次平仓)
   int counter=0;
   bool is_closed=false;
   while(counter<5 && !is_closed)
     {
      is_closed=trade.PositionClose(request_close);
      Sleep(10);
     }
   if(!is_closed)
     {
      RecordCloseFailed("仓位号/"+string(request_close)+" in "+__FUNCTION__);
      if(!PipeManager.WriteInteger(false))
        {
         RecordConnectionLoss(__FUNCTION__);
         return false;
        }
     }
   else
     {
      RecordSuccessInfor("平仓成功:仓位号/"+string(request_close)+" in " + __FUNCTION__);
      if(!PipeManager.WriteInteger(true))
        {
         RecordConnectionLoss(__FUNCTION__);
         return false;
        }
     }
   return true;
  }
void  CPipeBase::RecordConnectionLoss(string infor_print)
   {
    handle_state = ENUM_HANDLE_STATE_CONNECTION_LOSS;
    Print("###Pipe管道连接失败:",infor_print);
   }
void  CPipeBase::RecordOpenFailed(string infor_print)
   {
    handle_state = ENUM_HANDLE_STATE_OPEN_FAILED;
    Print("###开仓失败:",infor_print);
   }
void  CPipeBase::RecordCloseFailed(string infor_print)
   {
    handle_state = ENUM_HANDLE_STATE_CLOSE_FAILED;
    Print("###平仓失败:",infor_print);
   }
void  CPipeBase::RecordGetTickFailed(string infor_print)
   {
    handle_state = ENUM_HANDLE_STATE_GET_TICK_FAILED;
    Print("###获取tick失败:",infor_print);
   }
void  CPipeBase::RecordSuccessInfor(string infor_print)
   {
    Print("***操作成功:",infor_print);
   }
//+------------------------------------------------------------------+
