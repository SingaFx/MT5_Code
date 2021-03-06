//---------------------------------------------------------------------
#property copyright 	"Dima S., 2010 �"
#property link      	"dimascub@mail.com"
#property version   	"1.01"
#property description "价格列表, 使用 TextDisplay."
//---------------------------------------------------------------------
#property indicator_chart_window
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//	版本历史
//---------------------------------------------------------------------
//	07.10.2010� - V1.00
//	 - 首次发布
//
//	20.10.2010� - V1.01
//	 - 增加 - 设置表格输出的角度;
//	 - 增加 - 表格的水平和垂直转换;
//
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//	包含库
//---------------------------------------------------------------------
#include	<TextDisplay.mqh>
//---------------------------------------------------------------------

//=====================================================================
//	外部的输入参数
//=====================================================================
input ENUM_BASE_CORNER   Corner=CORNER_LEFT_UPPER;
input int               UpDownBorderShift=2;
input int               LeftRightBorderShift=1;
input color               TitlesColor=White;

//---------------------------------------------------------------------

//---------------------------------------------------------------------
TableDisplay      Table1;
//---------------------------------------------------------------------

#define	NUMBER	8
//---------------------------------------------------------------------
string   names[NUMBER]={ "EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCHF","USDCAD","USDJPY","EURJPY" };
int      c1_coord_y[ NUMBER ] = { 0,        1,        2,        3,        4,        5,        6,        7 };
int      c2_coord_y[ NUMBER ] = { 7,        6,        5,        4,        3,        2,        1,        0 };
//---------------------------------------------------------------------
double     rates[NUMBER];
datetime   times[NUMBER];
MqlTick    tick;
//---------------------------------------------------------------------
//	OnInit 事件处理函数
//---------------------------------------------------------------------
int OnInit()
  {
   ArrayInitialize(times,0);
   ArrayInitialize(rates,0);

//	创建表格
   Table1.SetParams(0,0,Corner);

//	显示价格
   for(int i=0; i<NUMBER; i++)
     {
      if(Corner==CORNER_LEFT_UPPER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+2,UpDownBorderShift+c1_coord_y[i],Yellow);
        }
      else if(Corner==CORNER_LEFT_LOWER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+2,UpDownBorderShift+c2_coord_y[i],Yellow);
        }
      else if(Corner==CORNER_RIGHT_UPPER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+2,UpDownBorderShift+c1_coord_y[i],Yellow);
        }
      else if(Corner==CORNER_RIGHT_LOWER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+2,UpDownBorderShift+c2_coord_y[i],Yellow);
        }
      else
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+2,UpDownBorderShift+c1_coord_y[i],Yellow);
        }
     }

//	显示点差
   for(int i=0; i<NUMBER; i++)
     {
      if(Corner==CORNER_LEFT_UPPER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+4,UpDownBorderShift+c1_coord_y[i],Yellow);
        }
      else if(Corner==CORNER_LEFT_LOWER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+4,UpDownBorderShift+c2_coord_y[i],Yellow);
        }
      else if(Corner==CORNER_RIGHT_UPPER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift,UpDownBorderShift+c1_coord_y[i],Yellow);
        }
      else if(Corner==CORNER_RIGHT_LOWER)
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift,UpDownBorderShift+c2_coord_y[i],Yellow);
        }
      else
        {
         Table1.AddFieldObject(40,40,LeftRightBorderShift+4,UpDownBorderShift+c1_coord_y[i],Yellow);
        }
     }

//	显示标题
   for(int i=0; i<NUMBER; i++)
     {
      if(Corner==CORNER_LEFT_UPPER)
        {
         Table1.AddTitleObject(40,40,LeftRightBorderShift,UpDownBorderShift+c1_coord_y[i],names[i]+":",TitlesColor);
        }
      else if(Corner==CORNER_LEFT_LOWER)
        {
         Table1.AddTitleObject(40,40,LeftRightBorderShift,UpDownBorderShift+c2_coord_y[i],names[i]+":",TitlesColor);
        }
      else if(Corner==CORNER_RIGHT_UPPER)
        {
         Table1.AddTitleObject(40,40,LeftRightBorderShift+4,UpDownBorderShift+c1_coord_y[i],names[i]+":",TitlesColor);
        }
      else if(Corner==CORNER_RIGHT_LOWER)
        {
         Table1.AddTitleObject(40,40,LeftRightBorderShift+4,UpDownBorderShift+c2_coord_y[i],names[i]+":",TitlesColor);
        }
      else
        {
         Table1.AddTitleObject(40,40,LeftRightBorderShift,UpDownBorderShift+c2_coord_y[i],names[i]+":",TitlesColor);
        }
     }

   RefreshInfo();
   ChartRedraw(0);

   EventSetTimer(1);

   return(0);
  }
//---------------------------------------------------------------------
//	OnCalculate 事件处理函数
//---------------------------------------------------------------------
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   return(rates_total);
  }
//---------------------------------------------------------------------
//	OnTimer 事件处理函数
//---------------------------------------------------------------------
void OnTimer()
  {
   RefreshInfo();
   ChartRedraw(0);
  }
//---------------------------------------------------------------------
//	OnDeinit 事件处理函数
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
   EventKillTimer();

//	删除表格
   Table1.Clear();
  }
//---------------------------------------------------------------------
//	刷新信息
//---------------------------------------------------------------------
void RefreshInfo()
  {
   for(int i=0; i<NUMBER; i++)
     {
      //	取得价格数据
      ResetLastError();
      if(SymbolInfoTick(names[i],tick)!=true)
        {
         Table1.SetText( i, "Err " + DoubleToString( GetLastError( ), 0 ));
         Table1.SetColor( i, Yellow );
         continue;
        }

      if(tick.time>times[i] || times[i]==0)
        {
         Table1.SetText(i,DoubleToString(tick.bid,(int)(SymbolInfoInteger(names[i],SYMBOL_DIGITS))));
         if(tick.bid>rates[i] && rates[i]>0.1)
           {
            Table1.SetColor(i,Lime);
           }
         else if(tick.bid<rates[i] && rates[i]>0.1)
           {
            Table1.SetColor(i,Red);
           }
         else
           {
            Table1.SetColor(i,Yellow);
           }

         rates[ i ] = tick.bid;
         times[ i ] = tick.time;
        }
      Table1.SetText(i+NUMBER,DoubleToString(( tick.ask-tick.bid)/SymbolInfoDouble(names[i],SYMBOL_POINT),0));
     }
  }
//+------------------------------------------------------------------+
