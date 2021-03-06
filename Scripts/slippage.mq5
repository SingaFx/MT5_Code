//+------------------------------------------------------------------+
//|                                                     sleppage.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#property script_show_inputs 
#include <Trade/Trade.mqh>;
#include <Trade/PositionInfo.mqh>;
#include <Trade/OrderInfo.mqh>;
input int magicidnumber = 123456;

string symbol_arr[30] = {"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY",
                        "EURGBP","EURAUD","EURNZD","EURCAD","EURCHF","EURJPY",
                        "GBPAUD","GBPNZD","GBPCAD","GBPCHF","GBPJPY",
                        "AUDNZD","AUDCAD","AUDCHF","AUDJPY",
                        "NZDCAD","NZDCHF","NZDJPY",
                        "CADCHF","CADJPY",
                        "CHFJPY",
                        "XAUUSD","XAGUSD"};
string filename = "deal_record.csv";
int opendir[30];
int opertype[30];
int symbol_count = 30;
double orderprice = 0.0;
double dealprice = 0.0;
int rangemin = 5;
int rangemax = 10;


CTrade trade;
CPositionInfo position;
uint begindeal = 0;// 记录下单的时间差用
bool isdealing = true; //判断是否交易
string dealingsymbol;
int lastdealcount ;
datetime beginruntime;
datetime ordertime;
int filehandle;

bool randomtrade(const string thesymbol)
{
	//对某个品种进行交易，如果没有他的仓位就
	int index = 0;
	//看一下该品种是否有仓位
	while(position.SelectByIndex(index++))
   {
      string tempsymbol;
      long  tempmagic;
      long tempticket;
      long temp_type; //仓位多空
      if(!position.InfoString(POSITION_SYMBOL,tempsymbol))
      {
         return false;
      }
      if(!position.InfoInteger(POSITION_MAGIC,tempmagic))
      {
         return false;
      }
      if(!position.InfoInteger(POSITION_TICKET,tempticket))
      {
         return false;
      }
      if(!position.InfoInteger(POSITION_TYPE,temp_type))
      {
         return false;
      }
      if(tempsymbol == thesymbol &&  tempmagic == magicidnumber) //找到了，那就平仓即可
      {
      	MqlTick temptick;
      	if(!SymbolInfoTick(thesymbol,temptick))
      		return false;
      	if(temp_type == POSITION_TYPE_BUY) //平多，卖，买价
      		orderprice = temptick.bid;
      	else
      		orderprice = temptick.ask;
      	Print("开始交易,交易品种",thesymbol,"平仓");
      	begindeal = GetTickCount();
   		ordertime = TimeLocal();      	
      	if(trade.PositionClose(tempticket))
      	{      		
      		isdealing = true;
      		return true;
      		//能够顺利平仓，获得tick价格
      	}
      	return false;
      }
   }
   //没有找到符合的品种，那就开仓了
   
	MqlTick temptick;
	
   if(!SymbolInfoTick(thesymbol,temptick))
   	return false;
   Print("开始交易,交易品种",thesymbol,"开仓");
   begindeal = GetTickCount();
   ordertime = TimeLocal();
	if(rand() > 16383 ) 
	{		
		//做多
		
		if(!trade.Buy(1,thesymbol))
		{
			return false;
		}
		isdealing = true;
		orderprice = temptick.ask; //做多卖价
		return true;
	}
	else
	{
	// 做空
		if(!trade.Sell(1,thesymbol))
		{
			return false;
		}
		isdealing = true;
		orderprice = temptick.bid;
		return true;
	}   
   return false;
}

int testdeal()
{//返回值 -1（交易超时等原因？） 0 (没有完成交易） 1(完成交易）
	if(!HistorySelect(beginruntime,TimeCurrent()))
	{
		Print("不能获得历史数据");
		return -1;
	}
	int tempdealcount = HistoryDealsTotal();
	//Print("历史订单数量",tempdealcount,"个");
	uint timenow = GetTickCount();
	if(timenow - begindeal > 60000) // 60秒没有成交？？？
		return -1;
	if( tempdealcount > lastdealcount)
	{//有新订单产生
		//在新交易中，寻找相同的eaid
		for(int i = lastdealcount ; i< tempdealcount  ;i++)
		{
			ulong theticket = HistoryDealGetTicket(i);
			//Print(HistoryDealGetInteger(theticket,DEAL_MAGIC),"  ",HistoryDealGetString(theticket,DEAL_SYMBOL),"  ",dealingsymbol);
			if(HistoryDealGetInteger(theticket,DEAL_MAGIC) == magicidnumber && HistoryDealGetString(theticket,DEAL_SYMBOL) == dealingsymbol)
			{
				MqlTick thetick;
				SymbolInfoTick(dealingsymbol,thetick);
				double mkprice = 0.0;
				if(HistoryDealGetInteger(theticket,DEAL_TYPE) == DEAL_TYPE_BUY)
					mkprice = thetick.ask;
				else
					mkprice = thetick.bid;
				
				FileWrite(filehandle,TimeToString(ordertime,TIME_DATE|TIME_SECONDS),
							TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS),GetTickCount()-begindeal,dealingsymbol,
							EnumToString(ENUM_DEAL_TYPE(HistoryDealGetInteger(theticket,DEAL_TYPE))),
							EnumToString(ENUM_DEAL_ENTRY(HistoryDealGetInteger(theticket,DEAL_ENTRY))),
							orderprice,mkprice,HistoryDealGetDouble(theticket,DEAL_PRICE),thetick.ask-thetick.bid);
				FileFlush(filehandle);
				//FileWrite(filehandle,"下单时间,成交时间,交易用时（毫秒）,交易品种,交易类型,开仓平仓,下单市价,成交市价,成交价格\n");//---
				//找到了订单了,交易完成了，写入文件
				
				isdealing = false;
				lastdealcount = tempdealcount;
				return 1;
			}
		}
		//所有都没有当前的数据，更新，继续等待有没有新的订单完成
		
	}
	lastdealcount = tempdealcount;
	return 0;
//如果有新的交易完成，范围true，否则范围false
}

void run()
{
	datetime nextordertime = TimeLocal();//获得当前时间
	MathSrand(GetTickCount());
	nextordertime += rand() % (rangemax-rangemin) + rangemin;// 每rangemin-rangemax秒交易一次，平均
	PrintFormat("开始脚本！\t下一次交易时间是:%s",TimeToString(nextordertime,TIME_DATE|TIME_SECONDS));
	lastdealcount = HistoryDealsTotal();
	filehandle = FileOpen(filename,FILE_CSV|FILE_WRITE|FILE_READ|FILE_SHARE_READ|FILE_ANSI,',');
	if(filehandle == INVALID_HANDLE)
		return;
	FileSeek(filehandle,0,SEEK_END);
	if(FileTell(filehandle) ==0)
	{
		FileWrite(filehandle,"下单时间,成交时间,交易用时（毫秒）,交易品种,交易类型,开仓平仓,下单市价,成交市价,成交价格,点差");
	}
	isdealing = false;
	dealingsymbol = "";
	testdeal();//一开始进行的是为了获得历史（程序开始到现在）订单数，应该是0的
	
	while(1)
	{
		if(isdealing)
		{
			int tempres = testdeal();
			if(tempres == -1)
			{
				Print("奇怪的错误！停止运行");
				return ;
			}
			if(tempres == 1)
			{
			//完成交易，可以进行下一次的交易了
				PrintFormat("%s:交易完成，总耗时%.3f秒",dealingsymbol,(GetTickCount()-begindeal)/1000.0);
				nextordertime = TimeLocal() + rand() % (rangemax-rangemin) + rangemin;
				PrintFormat("交易成功！\t下一次交易时间是:%s",TimeToString(nextordertime,TIME_DATE|TIME_SECONDS));
			}
			Sleep(1);
			continue;
		}
		//没有下单的时候
		if(TimeLocal() > nextordertime)
		{
			//达到下单的时间
			//首先选择下单的品种
			dealingsymbol = symbol_arr[rand() % 9];
			if(!randomtrade(dealingsymbol))
			{
				nextordertime = TimeLocal() + rand() % (rangemax-rangemin) + rangemin;
				PrintFormat("交易不成功！\t下一次交易时间是:%s",TimeToString(nextordertime,TIME_DATE|TIME_SECONDS));
			}
			continue;			
		}
		Sleep(1000);		
	}
}


void OnStart()
  {
  	beginruntime = TimeCurrent();
  	trade.SetExpertMagicNumber(magicidnumber);
  	Print("开始运行");
  	run();
//---
   
  }
//+------------------------------------------------------------------+
