//+------------------------------------------------------------------+
//|                                                        ewave.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.0"



#include <Trade/Trade.mqh>;
#include <Trade/PositionInfo.mqh>;
#include <Trade/OrderInfo.mqh>;

//斐波那契数列:1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,
//1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368


#define FatalErrorAndReturn fatalerror=true;return; 

CTrade trade;
COrderInfo order;
bool fatalerror = false;
CPositionInfo position;

input double shortvalue = 0.7;
input double longvalue	 = 0.3;//在0.3以下开多，在0.7以上开空




enum ESorce{
   Src_Open=0,
   Src_High=1,
   Src_Low=2,
   Src_Close=3,
   Src_HighLowavg=4,
   Src_OpenCloseavg=5,
   Src_Allavg=6
};

/*class PositionInfo
{
   //存放当前持仓的信息，并且用来判断能都加仓
public:
   //持仓订单的开仓时间
   datetime longtime[];
   datetime shorttime[];
   //开仓是所对应bar的时间
   datetime longbartime[];
   datetime shortbartime[];
   //每个订单持有的手数
   double longlots[];
   double shortlots[];
   //持有的订单数
   int longcount;
   int shortcount;
   

};*/



struct Order_info_data
{
   datetime ordertime;  //开仓订单成交的时间
   datetime bartime;    //开仓订单对应的bar时间
   double thelots;      //订单手数
   double theprice;     //成交金额
   ulong ticket;        //订单号
};

class PositionInfo_node
{
public:
   Order_info_data the_node_date;
   

   PositionInfo_node()
   {
      pnext = NULL;
   }
   bool SetPositionInfo(datetime ordertime,datetime bartime,double thelots,double theprice,ulong ticket)
   {
      the_node_date.ordertime = ordertime;
      the_node_date.bartime = bartime;
      the_node_date.thelots = thelots;
      the_node_date.theprice = theprice;
      the_node_date.ticket = ticket;
      return true;
   }
   bool Set_thenext(PositionInfo_node *thenext)
   {
      pnext = thenext;
      return true;
   }
   bool findordernum(ulong ticket)
   {
      if (the_node_date.ticket == ticket)
         return true;
      return false;
   }
   double Get_The_Price()
   {
      return the_node_date.theprice;
   }
   ulong Get_The_Ticket()
   {
      return the_node_date.ticket;
   }
   datetime Get_The_Tran_Time()
   {
      return the_node_date.ordertime;
   }
   datetime Get_The_Bar_time()
   {
      return the_node_date.bartime;
   }
public:
   PositionInfo_node * pnext;
   
};

class Link_PositionInfo
{
public:
   PositionInfo_node *head;

   Link_PositionInfo()
   {
      head = NULL;
      ordercount = 0;
   }
   ~Link_PositionInfo()
   {
      while(head)
      {
         PositionInfo_node * current = head;
         head = head.pnext;
         delete current;
      }
   }
   bool AddOrder(datetime ordertime,datetime bartime,double thelots,double theprice,ulong ticket)
   {//将订单信息写入，插入链表最前；
      PositionInfo_node *temp_node = new PositionInfo_node();
      temp_node.SetPositionInfo(ordertime,bartime,thelots,theprice,ticket);
      temp_node.Set_thenext(head);
      head = temp_node;
      ordercount ++;
      return true;
   }
   bool DeleteOrder(ulong ticket)
   {//在仓位链表中删除为ordernum的信息
      PositionInfo_node *prev = NULL;
      PositionInfo_node * current = head;
      while(current)
      {
         if(current.findordernum(ticket))
         {//找到订单，退出就是了
            break;
         }
         //没有找到，那就找下一个
         prev=current;
         current = current.pnext;
      }
      //有几个可能，
      //1、head点就是该订单，有prev=NULL，current！=NULL
      if(prev==NULL && current!=NULL)
      {//删除head节点
         PositionInfo_node * temp = head;
         head = head.pnext;
         delete temp;
         ordercount --;
         return true;
      }
      //2、prev!=NULL ,current !=NULL)
      if(prev && current)
      {//在非head节点找到了该订单
           PositionInfo_node * temp = current;
           prev.pnext = current.pnext;
           delete temp;
           ordercount --;
           return true;
      }
      //3、current ==NULL，找不到订单信息，
      return false;
   }
   double Get_Order_Price_i(int theindex)
   {
      PositionInfo_node *temp = head;
      if(!temp)return -1;
      int i = 0;
      while(i<theindex)
      {
         i++;
         temp = temp.pnext;
         if(!temp)return -1;
      }
      return temp.Get_The_Price();
   }
   double Get_Order_Price_t(ulong ticket)
   {
      PositionInfo_node *temp = head;
      if(!temp)return -1;
      while(ticket!=temp.Get_The_Ticket())
      {
         temp = temp.pnext;
         if(!temp)return -1;
      }
      return temp.Get_The_Price();
   }
   
   datetime Get_Order_Tran_Time_i(int theindex)
   {
      PositionInfo_node *temp = head;
      if(!temp)return 0;
      int i = 0;
      while(i<theindex)
      {
         i++;
         temp = temp.pnext;
         if(!temp)return 0;
      }
      return temp.Get_The_Tran_Time();
   }
   
   datetime Get_Order_Tran_Time_t(ulong ticket)
   {
      PositionInfo_node *temp = head;
      if(!temp)return 0;
      while(ticket!=temp.Get_The_Ticket())
      {
         temp = temp.pnext;
         if(!temp)return 0;
      }
      return temp.Get_The_Tran_Time();
   }
   
   
   
   
   ulong Get_Order_ticket(int theindex)
   {
      PositionInfo_node *temp = head;
      if(!temp)return 0;
      int i = 0;
      while(i<theindex)
      {
         i++;
         temp = temp.pnext;
         if(!temp)return 0;
      }
      return temp.Get_The_Ticket();
   }
   
   int ordercount;
};
struct control_position
{
   Link_PositionInfo longposition; //多仓持仓信息
   Link_PositionInfo shortposition;//空仓持仓信息
   int longcontrol ;
   int shortcontrol ;
   control_position()
   {
      longcontrol = 0;
      shortcontrol = 0;
   }

//b'00'，无预制开仓，b'1x',需要与当前最近开仓的对比时间开仓，b'x1'需要与当前最近开仓的对比价格开仓

};

control_position orderlist;
control_position virtualorderlist; //模拟订单，模拟扛单的效果

enum orderstats
{
   donone = 0,
   buyin = 1,
   buyout = 2,
   sellin = 3,
   sellout = 4,
};
orderstats virtualorderstats=donone;  //模拟单状态，1，buyin，2，buyout，3，sellin，4，sellout




//input 
//倍数
int totallevel = 15;//最多20级
double beishu = 1;
double beishu1 = 1;
double beishu2 = 1;
//double multi[] = {1.0,1.0,1.5,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.5,10.0,11.5,13.0,15.0,17.0,19.0,22.0};
double multi[] =   {1.0,1.5,2.0,3.0,4.0,5.5,7.0,9.0,11.0,13.5,16.0,19.0,22.0,25.5,29.0}; //每级对应的倍数
double multi2[] =  {1.0,2.5,4.5,7.5,11.5,17,24,33,44,57.5,73.5,92.5,114.5,140,169}; //每级对应的累计倍数

//halifaxplus平台，美日/黄金的理想下单手数比例为1/8，因此1等级的下单为0.05/0.4
//Alpari平台，美日/黄金的理想下单手数比为5/4，因此1等级的下单为0.05/0.04

double the_lots_1 = 1*beishu; //每次下单的基本倍数的手数 品种1为黄金，品种2为美日
double the_lots_2 = 1*beishu;
//double longvalue_arr[] = {0.2,0.17,0.14,0.11,0.08,0.05,0.02,-0.00001};//0.09,0.06,0.03,-0.00001}; //11个数，对应着10个级别，其中第10级别为亏损加仓级别，也就是达到这个级别后，每当亏损到一定程度，加仓一次。
//double shortvalue_arr[]= {0.8,0.83,0.86,0.89,0.92,0.95,0.98,1.00001};//0.91,0.94,0.97,1.00001};//设置不同等级应该对应的等级

double longvalue_arr[] = {0.2,0.15,0.1,0.05,-0.00001};//0.09,0.06,0.03,-0.00001}; //11个数，对应着10个级别，其中第10级别为亏损加仓级别，也就是达到这个级别后，每当亏损到一定程度，加仓一次。
double shortvalue_arr[]= {0.8,0.85,0.9,0.95,1.00001};//0.91,0.94,0.97,1.00001};//设置不同等级应该对应的等级

double profit_target1 = 120*beishu;//达到出场条件（0.2，0.35）（0.65，0.85）并且每级倍数盈利金额也达到，出场
int sl_level = 3;//当达到反向等级时，不管盈利必须要出场，
int max_level = 4;
double profit_target2 = 240*beishu;//当处于对面的均衡 区(0.36,0.5)(0.5,0.65),并且每级倍数盈利金额也达到，出场
int dif_level = 2; //开仓是，必须要跟反向超过该级别，例如空1，则，达到空3或者达到多1时才能进场
int add_lost_pershard = 120;//在达到极限后，判断入场后亏损再加大到该数值时加仓
int add_lost_permul = 30;
int ewillam_heldg_handle=  INVALID_HANDLE;
int testhandle = INVALID_HANDLE;
string   othersymbol; //套利品种另外一个的symbol
string the_symbol1 = "XAUUSD";
string the_symbol2 = "USDJPY";
string symbol1 ;//实际上要在init函数里面来设置他们的值，要确定symbol1 = symbol，而symbol2是它的对冲品种
string symbol2 ;
int minorderdigits = 2; //最小能小0.01手
int min_interval = 30*60;//最小加仓间隔时间1800秒
long themagicid = 20171017; //for黄金美日
int trademode = 2; //1:普通加仓模式，2，不加仓模式，3，加时间间隔的加仓模式，6//带上时间止损的模式
double set_losts = 500000*beishu1;
int opendir = 0;//判断系统是否已经在之前就有了开仓，如果有，需要获得相关信息。

void Judge_Level(int & dir,int &level,double value)
{
	dir = 0;
	level = 0;
	value = value -1; //原有数据在1-2之间，转换为0-1之间。
	if (value < 0 || value > 1) return ; //防止指标计算出错需要重算了，出现异常的数据导致进出场
	for(int i = 0;i<ArraySize(longvalue_arr)-1;i++) //强超卖
	{
		if(value > longvalue_arr[i+1] && value < longvalue_arr[i])//等级从1开始
		{
			dir = 1 ;
			level = i +1;
			return ;
		}
	}
	for(int i = 0;i<ArraySize(shortvalue_arr)-1;i++) //强超买
	{
		if(value > shortvalue_arr[i] && value < shortvalue_arr[i+1])
		{
			dir = -1;
			level = i+1;
			return ;
		}
	}
	//如果都不是，那么就判断是不是弱超
	if(value>=0.65 && value <= shortvalue_arr[0])//弱超卖
	{
	   dir = -1;
	   level = 0;
	   return ;
	}
	if(value<=0.35 && value >= longvalue_arr[0])//弱超买
	{
	   dir = 1;
	   level = 0;
	   return ;
	}
	if(value>=0.5 && value < 0.65)//均衡1
	{
	   dir = -1;
	   level = -1;
	   return ;
	}
	if(value<0.5 && value > 0.35)//均衡2
	{
	   dir = 1;
	   level = -1;
	   return ;
	}
	
}

void PositionCloseAll()
{ //平掉账户的所有持仓

   for(int i = PositionsTotal()-1;i>=0;i--)
   {  
      ulong temptickect = PositionGetTicket(i);
      if(!PositionSelectByTicket(temptickect)) {Print("Error in PositionClossAll_PositionSelectByTicket()");return;}//异常，不处理
      string tempsymbol = PositionGetString(POSITION_SYMBOL);
      long tempmacid = PositionGetInteger(POSITION_MAGIC);//获得了symbol和magic,对于EA对应的品种，全部平掉
      if((StringCompare(tempsymbol,symbol1) == 0  || StringCompare(tempsymbol,symbol2) ==0)&& tempmacid == themagicid)//对应上了
         if(!trade.PositionClose(temptickect))
         {
            Print("Can't Close the Position:",temptickect);
         }
      
      
      
   }
   return ;//
   while(trade.PositionClose(symbol2))
   {//先平掉symbol1的仓位
      continue;
   }
   while(trade.PositionClose(symbol1))
   {
      continue;
   }
   
}
bool FindProfit_Vol(double &profit,double &vol) //获得对应symbol的总收益和总单
{
   profit = 0.0f;
   vol = 0.0f;
   int index = 0;
   while(position.SelectByIndex(index++))
   {
      string tempsymbol;
      double curprofit;
      double curvol;
      long  tempmagic;
      if(!position.InfoString(POSITION_SYMBOL,tempsymbol))
      {
         return false;
      }
      if(!position.InfoDouble(POSITION_PROFIT,curprofit))
      {
         return false;
      }
      if(!position.InfoDouble(POSITION_VOLUME,curvol))
      {
         return false;
      }
      if(!position.InfoInteger(POSITION_MAGIC,tempmagic))
      {
         return false;
      }
      if((tempsymbol == symbol1 || tempsymbol == symbol2)&& tempmagic == themagicid)
      {
         profit += curprofit;
         vol += curvol;
      }
   }
   return true;
//
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   opendir = 0;//最开始，置为没有开仓
   Print("Begin of Init");
   if(StringCompare(Symbol(),the_symbol1)==0)
   {
      symbol1 = the_symbol1;
      symbol2 = the_symbol2;
   }
   else if(StringCompare(Symbol(),the_symbol2)==0)
   {
      symbol1 = the_symbol2;
      symbol2 = the_symbol1;
   }
   else
   {
      Print("wrong symbol:",Symbol());
      return(INIT_FAILED);
   }//这样子确保了symbol1就是当前品种，那么可以认为Ontick触发是，symbol1必定处于可以交易的状态。
   //获取当前账号已经开仓的信息，如果有，需要更新判断是否有异常
   
   int index = 0;
   
   while(position.SelectByIndex(index++))
   {
      string tempsymbol;
      long  tempmagic;
      int tempdir;
      long temptype;//buy还是sell
      if(!position.InfoString(POSITION_SYMBOL,tempsymbol))
      {
         continue;
      }
      
      if(!position.InfoInteger(POSITION_MAGIC,tempmagic))
      {
         continue;
      }
      if(!position.InfoInteger(POSITION_TYPE,temptype))
      {
         continue;
      }
      //对于黄金美日，是两个同时多，或者同时空，从他的买入方向来判断当前策略是什么情况。
      if((tempsymbol == symbol1 ||tempsymbol == symbol2) && tempmagic == themagicid)
      {
         
         if(temptype == POSITION_TYPE_BUY)//做多
            tempdir = 1;
         else
            tempdir = -1;
         if(opendir + tempdir == 0)//之前设置的开仓方向与他不相符，说明有异常，需要停止
         {
            Print("开仓的方向出现冲突异常");
            PositionCloseAll();
            opendir = 0;//全部清仓，重零开始
            break;
         }
         opendir = tempdir;
      }
      else
      {continue;}
      
   }
   double tempprofit,tempvol;
   FindProfit_Vol(tempprofit,tempvol);
   if ((opendir == 0 && tempvol >0.00001)||(opendir!=0 && tempvol<0.00001))
   {
      Print("Error in find the order direction,%d  %f",opendir,tempvol);
      return(INIT_FAILED);
   }
	/*if(trademode !=2)
	{
		if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
		{
			Alert("is not a netting mode,system not support");//不是单边持仓模式，不支持
			fatalerror = true;
			return (INIT_FAILED);
		}//仅仅在不加仓模式，就是ontick2中，可以使用对冲账户
	}
   Print("initing123");*/
   ewillam_heldg_handle = iCustom(Symbol(),Period(),"william_heldgxau_usdjp");
   
   //SetIndexBuffer(0,wave,INDICATOR_DATA);
   
   //testhandle = iCustom(Symbol(),Period(),"boll_heldg_xau_usdjpy");
   
   if(ewillam_heldg_handle==INVALID_HANDLE)
   {
      Alert("Error load ewillam_heldg_handle indicator");
      fatalerror = true;
      return(INIT_FAILED);
   }
   //*/
   if(StringCompare(Symbol(),symbol1)==0)
   {
		othersymbol=symbol2;
   }
   else if(StringCompare(Symbol(),symbol2)==0)
	{
		othersymbol=symbol1;
	}
   else
	{
		Alert("wrong symbol:",Symbol());
		fatalerror = true;
		return(INIT_FAILED);
	}
	trade.SetExpertMagicNumber(themagicid);
    
//--- create timer
   //EventSetTimer(60);
   Print("End of Init, success"); 
   Print("Opendir:",opendir);
   Print("Positiontotal:",index);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   /*MqlTick last_tick,other_last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick)||!SymbolInfoTick(othersymbol,other_last_tick))
   {
      Print("slkdf");
   	return ;//获得最新tick出现错误。
   }
   //Print("kkkk");//*/
   //return ;
	switch(trademode)
	{
		case 1:OnTick1();break;
		case 2:OnTick2();break;
		case 3:OnTick3();break;
	}
	
}

void OnTick1()
{	//mode1，可以在极短的时间里面多次加仓。
	if(fatalerror) 
	{/*//如果出错，就不在进行处理
   	Alert("aaa");//*/
   	return;
	}
	
	//trade.Buy(1.23,symbol1);
	//trade.Buy(2,34,symbol2);
	//fatalerror = true;
	//return ;
	datetime tm[1],othertm[1];
	if(CopyTime(Symbol(),Period(),0,1,tm)<=0)return; //当前所在bar的时间
   if(CopyTime(othersymbol,Period(),0,1,othertm)<=0)return; //当前所在bar的时间
   
   if(tm[0]!=othertm[0])
   {
   	return;//,不在一个bar上面，等同在bar再处理
   }
   //同在一个bar了
   MqlTick last_tick,other_last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick)||!SymbolInfoTick(othersymbol,other_last_tick))
   {
   	return ;//获得最新tick出现错误。
   }
   //获得了最新的各自的tick
   //如果两个tick之间的时间差超过2s，说明很可能交易非常少，或者就是有一个不在交易时间内了
   if(MathAbs(last_tick.time_msc-other_last_tick.time_msc) > 2000)
   {
   	return ;
   }
   //两个tick的时间足够接近了
   //判断当前tick的价差的威廉水平
   double heldg_william[1];
   if(CopyBuffer(ewillam_heldg_handle,0,0,1,heldg_william)<=0)
   {//找不到当前的指标值
   	return;
   }
   int dir = 0;   //开多 1开多，-1，开空，0，无方向
   int level = 0; //对应等级
   
   //获得当前的值对应的等级
   //static int opendir = theopendir;
   static int openlevel = 0;
   static int closedir = 0;
   static int closelevel = 0;
   static int maxdir = 0;
   //static int maxlevel = 0;  // 用来判断能否入场、加仓的值，如果跳若干个级才能入场或者加仓mode1不支持
   
   static int empty_max = 0; // 空仓时指标最大去到的等级。（由-10 -- 10，0为无方向）
   static int empty_min = 0;
   static int cumlevel = 0 ; //当前累加等级，用来在入场和加仓的时候寻找入场的手数 
   static double cumvol_1 = 0.0;
   static double cumvol_2 = 0.0;
   
   static double lastprofit_pershard = 0.0;//最近一次入场、加仓时的总亏损程度 
   static double lastprofit_permul = 0.0;//最近一次入场、加仓时的总亏损程度 
   
   Judge_Level(dir,level,heldg_william[0]);
   static datetime opentime;
   static int openmaxlevel = 0;
   static double openmaxloss = 0;
   
   
   //double vol1,vol2,profit1,profit2;
   double totalprofit ;//= profit1 + profit2;
   double totalvol 	 ;//= cumvol_1 + cumvol_2;
   int dir1,dir2;
   FindProfit_Vol(totalprofit,totalvol);
   if(MathAbs(cumvol_1 +cumvol_2 - totalvol) >0.000001 )
   {
   	//实际持仓跟计算持仓不一致，
   	Alert("The Position is not correct! cumvol_1:",cumvol_1,"  vumvol_2:",cumvol_2,"  total:",totalvol);
   	
   	fatalerror = true;
   	return ;
   }
   
   //不在考虑是否持仓一致的，因为在锁仓模式当中，没有办法来判断总的仓位*/
   //double totalprofit = profit1 + profit2;
   //double totalvol 	 = cumvol_1 + cumvol_2;
  	
   //Print("profit_per_shard:",totalvol>0.000001?totalprofit / totalvol:0,", lastprofit_pershard:",lastprofit_pershard);
   
   
   if(totalvol <  0.000001)//空仓
   {
   	//判断并更新当前的最大等级
   	
   	//查看是否等开仓
   	
   	//if(level*dir-empty_min >= dif_level && dir >0) // 达到做多的条件
   	if(level > 0 && dir >0)//达到做多的条件
   	{
   		
   		double v1 = NormalizeDouble(the_lots_1*multi[0],minorderdigits);
   		double v2 = NormalizeDouble(the_lots_2*multi[0],minorderdigits);
   		//进场做多，
   		string  comment= "做多等级"+IntegerToString(1);
   		if(!trade.Buy(v1,symbol1,0,0,0,comment))
   		{
   			Alert("can't open long position",symbol1);
   			return ;
   		}
   		if(!trade.Buy(v2,symbol2,0,0,0,comment))
   		{
   			Alert("can't open long position",symbol2);
   			trade.PositionClose(symbol1);//如果这个没法开仓，但是上一个已经开仓了，所以要平掉
   			//并且要设置当前为错误的状态
   			fatalerror =true;
   			return ;
   		}
   		
   		opendir = dir;
   		openlevel = level;
   		cumvol_1 = v1;
   		cumvol_2 = v2;
   		opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   		openmaxlevel = level;
   		openmaxloss = 0.0;
   		cumlevel = 1;
   		return;
   	}
   	//else if(empty_max - level*dir >=dif_level && dir < 0 ) //达到做空的条件
   	else if(level>0 && dir <0) //达到做空的条件
   	{
   		
   		//进场做空，
   		double v1 = NormalizeDouble(the_lots_1*multi[0],minorderdigits);
   		double v2 = NormalizeDouble(the_lots_2*multi[0],minorderdigits);
   		string  comment= "做空等级"+IntegerToString(0+1);
   		if(!trade.Sell(v1,symbol1,0,0,0,comment))
   		{
   			Alert("can't open short position",symbol1);
   			return ;
   		}
   		if(!trade.Sell(v2,symbol2,0,0,0,comment))
   		{
   			Alert("can't open short position",symbol2);
   			trade.PositionClose(symbol1);//如果这个没法开仓，但是上一个已经开仓了，所以要平掉
   			PositionCloseAll();
   			//并且要设置当前为错误的状态
   			fatalerror =true;
   			return ;
   		}
   		
   		opendir = dir;
   		openlevel = level;
   		cumvol_1 = v1;
   		cumvol_2 = v2;
   		lastprofit_pershard = 0.0;
   		opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   		openmaxlevel = level;
   		openmaxloss = 0.0;
   		cumlevel =1;
   		return;
   	}
   	else
   	{//不处理
   	return;
   	//既不做多，也不做空，那就更新空仓的信息
   	empty_max = MathMax(empty_max,level*dir);
   	empty_min = MathMin(empty_min,level*dir);
   	return;
   	//空仓，但是什么条件都不符合，不return也是应该没有代码要执行了
   	}
   }
   else//有仓位
   {
      double profit_per_mul = totalprofit / multi2[cumlevel-1];//每基准倍数盈利情况
      double profit_per_shard = totalprofit / totalvol;
      //判断是否到达对面的位置
      if(opendir != dir) //方向已经发生改变，那么就可以判断是否可以平仓了
      {
         
   	   //有仓位了，那么就要判断是否要加仓或者是离场了
   	   //首先判断收益是否达到可以离场的条件了
   	   //获得账户的盈利情况并计算平均没有盈利
      	
   	   //if(profit_per_shard>profit_target2||
   	   //	((profit_per_shard>profit_target1||level>=sl_level)&&dir!=opendir))//可以离场了
         if(level > 0  || //达到强超不管是否盈利均要出场
            (level == 0 && profit_per_mul > profit_target1 ) || //达到弱超，每基础倍数盈利达到目标1
            (level < 0 && profit_per_mul > profit_target2 ))    //达到强超，每基础倍数盈利达到目标2
            //可以离场了
   	   {
   		   /*bool res1 = trade.PositionClose(symbol1);
   		   bool res2 = trade.PositionClose(symbol2);
   		   if(!(res1 && res2))
   		   {
   			   Alert("Error in PositionClose: ",res1,res2);
   			   fatalerror = true;
   			   return ;
   		   }
   		   */
   		   PositionCloseAll();
      		
      		
   		   closedir = dir;
   		   closelevel = level;
   		   cumlevel = 0;
   		   cumvol_1 = 0.0;
   		   cumvol_2 = 0.0;
   		   empty_max = dir * level;
   		   empty_min = dir * level;
   		   lastprofit_pershard = 0.0;
   		   lastprofit_permul = 0.0;
   		   opentime = 0;
   		   openmaxlevel = 0;
   		   openmaxloss = 0.0;
   		   	
   	   }
   	   return;
   	}
   	//方向还没有改变，判断是否可以加仓
   	
   	
   	//判断是否要加仓
   	
   	//超出最小加仓间隔的了，可以考虑加仓
   	if(opendir == dir && level > openlevel )//达到加仓的条件(1.同向, 2，越级，3超出间隔时间内的最大级)
   	{
   		//根据当前的cumlevel来加仓
   		if(dir >0)
   		{//加仓多
   			//进场做多，未完成
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做多等级"+IntegerToString(cumlevel+1);
   			if(!trade.Buy(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol1);
   				return ;
   			}
   			if(!trade.Buy(v2,symbol2,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol2);
   				//trade.Sell(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; //入场后，每基准倍数亏损的情况会得到减弱
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_permul;
   			
   			cumlevel ++;
   		}
   		if(dir<0)
   		{//加仓空
   			//进场做空，
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做空等级"+IntegerToString(cumlevel+1);
   			if(!trade.Sell(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add short position",symbol1);
   				return ;
   			}
   			if(!trade.Sell(v2,symbol2,0,0,0,comment))
   			{
   				Alert("can't add short position",symbol2);
   				//trade.Buy(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; //入场后，每基准倍数亏损的情况会得到减弱
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_permul;
   			cumlevel ++;
   		}
   		
   		//opendir = dir;
   		//openlevel = level;
   		//cumlevel ++;
   		return ;
   	}
   	//如果已经达到最最大级别就是0-0.03，和0.97-1时，按照每手亏损情况来加仓。
   	if(level ==openlevel && level == max_level && cumlevel < totallevel)//当达到极端的情况是
   	{
   		//获得账户的亏损情况，计算每手亏损，然后根据cumlevel来，计算加仓阈值，然后判断当前每手亏损是否已经达到了这个阈值
   		if((lastprofit_permul-profit_per_mul)<add_lost_permul ) //亏损使用负数来表示的lastprofit_pershard > openmaxloss就是当前的亏损要比间隔时间内的亏损要少，那就不考虑了
   		{
   			//没有达到加仓的条件
   			return;
   			
   		}
   		//相比上一次加仓的每手亏损，此次每手亏损超出了加仓的阈值，可加仓
   		//根据当前的cumlevel来加仓，未完成
   		if(dir >0)
   		{//加仓多
   			//进场做多，
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做多等级"+IntegerToString(cumlevel+1);
   			if(!trade.Buy(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol1);
   				return ;
   			}
   			if(!trade.Buy(v2,symbol2,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol2);
   				//trade.Sell(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; //入场后，每基准倍数亏损的情况会得到减弱
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_pershard;
   			cumlevel ++;
   		}
   		if(dir<0)
   		{//加仓空
   			//进场做空，
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做空等级"+IntegerToString(cumlevel+1);
   			if(!trade.Sell(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add short position",symbol1);
   				return ;
   			}
   			if(!trade.Sell(v2,symbol2,0,0,0,comment))
   			{
   				Alert("can't add short position",symbol2);
   				//trade.Buy(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; //入场后，每基准倍数亏损的情况会得到减弱
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_pershard;
   			cumlevel ++;
   		}
   		return;
   	}
   	//什么也没有，return不return都可以了
   	return;
   }
}


void OnTick2()
{	//mode12，不加仓模式。
	if(fatalerror) 
	{//*//如果出错，就不在进行处理
   	//Alert("aaa");//*/
   	return;
	}
	static int totallost = 0;
	static int lost_stats = 0; //止损是处于什么模式
	//trade.Buy(1.23,symbol1);
	//trade.Buy(2,34,symbol2);
	//fatalerror = true;
	//return ;
	datetime tm[1],othertm[1];
	if(CopyTime(Symbol(),Period(),0,1,tm)<=0)return; //当前所在bar的时间
   if(CopyTime(othersymbol,Period(),0,1,othertm)<=0)return; //当前所在bar的时间
   
   if(tm[0]!=othertm[0])
   {
   	return;//,不在一个bar上面，等同在bar再处理
   }
   //同在一个bar了
   MqlTick last_tick,other_last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick)||!SymbolInfoTick(othersymbol,other_last_tick))
   {
   	return ;//获得最新tick出现错误。
   }
   //获得了最新的各自的tick
   //如果两个tick之间的时间差超过5s，说明很可能交易非常少，或者就是有一个不在交易时间内了
   if(MathAbs(last_tick.time_msc-other_last_tick.time_msc) > 5000)
   {
   	return ;
   }
   //两个tick的时间足够接近了
   //判断当前tick的价差的威廉水平
   double heldg_william[1];
   if(CopyBuffer(ewillam_heldg_handle,0,0,1,heldg_william)<=0)
   {//找不到当前的指标值
   	return;
   }
   int dir = 0;   //开多 1开多，-1，开空，0，无方向
   int level = 0; //对应等级
   
   //获得当前的值对应的等级
   //static int opendir = theopendir;
   static int openlevel = 0;
   static int closedir = 0;
   static int closelevel = 0;
   static int maxdir = 0;
   //static int maxlevel = 0;  // 用来判断能否入场、加仓的值，如果跳若干个级才能入场或者加仓mode1不支持
   
   static int empty_max = 0; // 空仓时指标最大去到的等级。（由-10 -- 10，0为无方向）
   static int empty_min = 0;
   static int cumlevel = 0 ; //当前累加等级，用来在入场和加仓的时候寻找入场的手数 
   static double cumvol_1 = 0.0;
   static double cumvol_2 = 0.0;
   static double lastprofit_pershard = 0.0;//最近一次入场、加仓时的总亏损程度 
   
   Judge_Level(dir,level,heldg_william[0]);
   if(dir ==0) return ;//有可能是计算指标出错，退出就是了
   static datetime opentime;
   static int openmaxlevel = 0;
   static double openmaxloss = 0;
   
   
   //double vol1,vol2,profit1,profit2;
   double totalprofit ;//= profit1 + profit2;
   double totalvol 	 ;//= cumvol_1 + cumvol_2;
   int dir1,dir2;
   FindProfit_Vol(totalprofit,totalvol);
   /*if(MathAbs(cumvol_1 +cumvol_2 - totalvol) >0.000001 )
   {
   	//实际持仓跟计算持仓不一致，
   	Alert("The Position is not correct! cumvol_1:",cumvol_1,"  vumvol_2:",cumvol_2,"  total:",totalvol);
   	
   	PositionCloseAll();//防止程序以外停止后重启，必须要以空仓开始。
   	cumlevel = 0;
   	cumvol_1 = 0.0;
      cumvol_2 = 0.0;
   	return ;
   }*/
  	
   //Print("profit_per_shard:",totalvol>0.000001?totalprofit / totalvol:0,", lastprofit_pershard:",lastprofit_pershard);
   if((opendir ==0 && totalvol >  0.000001) ||(opendir !=0 && totalvol <  0.000001))  //一个显示为持仓，一个显示为没有持仓，有冲突
   {
      Print("Error! different order status,%d  %f",opendir,totalvol);
      fatalerror = true;
      return ;
   }
   
   
   
   if(totalvol <  0.000001)//查看是否为空仓
   {
   	//判断并更新当前的最大等级
   	
   	//查看是否等开仓
   	
   	//if(level*dir-empty_min >= dif_level && dir >0) // 达到做多的条件
   	if(level > 0 && dir >0)//达到做多的条件
   	{
   	   if(lost_stats > 0) //上一次是止损做多的，就是状态没有根本的变化，不进场
   		   return;
   		lost_stats =0; //
   		
   		if(symbol1 == "XAUUSD")
   		   the_lots_1 = the_lots_2 * 1000 / last_tick.bid;
   		else
   		   the_lots_2 = the_lots_1 * 1000 / other_last_tick.bid; 		   
   		
   		
   		
   		double v1 = NormalizeDouble(the_lots_1*multi[0],minorderdigits);
   		double v2 = NormalizeDouble(the_lots_2*multi[0],minorderdigits);
   		//进场做多，
   		string  comment= "做多等级"+IntegerToString(0+1);
   		if(!trade.Buy(v2,symbol2,0,0,0,comment))//首先要买入不能确定能交易的品种
   		{
   		   PositionCloseAll();
   			Alert("can't open long position2：",symbol2);
   			return ;
   		}
   		if(!trade.Buy(v1,symbol1,0,0,0,comment))//再买入确定能交易的品种
   		{
   			Alert("can't open long positio:1：",symbol1);
   			PositionCloseAll();;//如果这个没法开仓，但是上一个已经开仓了，所以要平掉
   			//并且要设置当前为错误的状态
   			//fatalerror =true;
   			return ;
   		}
   		Print("Open Long, dir:",dir,", level:",level);
   		opendir = dir;
   		cumvol_1 = v1;
   		cumvol_2 = v2;
   		cumlevel =1;
   	}
   	//else if(empty_max - level*dir >=dif_level && dir < 0 ) //达到做空的条件
   	else if(level > 0 && dir <0)//达到做kong的条件
   	{
   	   if(lost_stats < 0) //上一次是止损做空的，就是状态没有根本的变化，不进场
   		   return;
   		lost_stats =0; //
   		if(symbol1 == "XAUUSD")
   		   the_lots_1 = the_lots_2 * 1000 / last_tick.bid;
   		else
   		   the_lots_2 = the_lots_1 * 1000 / other_last_tick.bid;
   		
   		
   		//进场做空，
   		double v1 = NormalizeDouble(the_lots_1*multi[0],minorderdigits);
   		double v2 = NormalizeDouble(the_lots_2*multi[0],minorderdigits);
   		string  comment= "做空等级"+IntegerToString(0+1);
   		if(!trade.Sell(v2,symbol2,0,0,0,comment))
   		{
   			Alert("can't open short position2：",symbol2);
   			PositionCloseAll();
   			return ;
   		}
   		if(!trade.Sell(v1,symbol1,0,0,0,comment))
   		{
   			Alert("can't open short position1：",symbol1);
   			PositionCloseAll();;//如果这个没法开仓，但是上一个已经开仓了，所以要平掉
   			//并且要设置当前为错误的状态
   			//fatalerror =true;
   			return ;
   		}
   		Print("Open Short, dir:",dir,", level:",level);
   		opendir = dir;
   		cumvol_1 = v1;
   		cumvol_2 = v2;
   		cumlevel =1;
   	}
   	return;
   }
   else//有仓位
   {
      //Print(opendir);
      double profit_per_mul = totalprofit / multi2[0];//每基准倍数盈利情况
      double profit_per_shard = totalprofit / totalvol;
      //判断是否需要止损
      if(profit_per_mul < 0-set_losts)
      {
         //止损
         lost_stats = dir;
         PositionCloseAll();
         cumvol_1 = 0.0;
   		cumvol_2 = 0.0;
   		totallost ++;
   		Print("PositionSetLost, dir:",dir,", level:",level,", profit_per_mul:",profit_per_mul,", opendir:",opendir);
   		Print("totallost:",totallost);
   		//opendir = 0;
   		return;
      }
      //判断是否到达对面的位置
      if(opendir != dir) //方向已经发生改变，那么就可以判断是否可以平仓了
      {
         
   	   //有仓位了，那么就要判断是否要加仓或者是离场了
   	   //首先判断收益是否达到可以离场的条件了
   	   //获得账户的盈利情况并计算平均没有盈利
      	
   	   //if(profit_per_shard>profit_target2||
   	   //	((profit_per_shard>profit_target1||level>=sl_level)&&dir!=opendir))//可以离场了
         if(level == 0  || //达到强超不管是否盈利均要出场
            (level < 0 && profit_per_mul > profit_target1 ))// || //达到弱超，每基础倍数盈利达到目标1
            //(level < 0 && profit_per_mul > profit_target2 ))    //达到均衡，每基础倍数盈利达到目标2
            //可以离场了
   	   {
   		   /*bool res1 = trade.PositionClose(symbol1);
   		   bool res2 = trade.PositionClose(symbol2);
   		   if(!(res1 && res2))
   		   {
   			   Alert("Error in PositionClose: ",res1,res2);
   			   fatalerror = true;
   			   return ;
   		   }*/
   		   PositionCloseAll();
      		Print("PositionClose, dir:",dir,", level:",level,", profit_per_mul:",profit_per_mul,", opendir:",opendir);
      		
   		   cumvol_1 = 0.0;
   		   cumvol_2 = 0.0;
   		   	
   	   }
   	   return;
   	}
   }
}

void OnTick3()
{	//模式三，增加了加仓最短间隔时间，在间隔时间内不允许加仓，并且记录在这个间隔时间内，价格（亏损）的最大偏移程度，作为下一次开仓参考点
	if(fatalerror) 
	{/*//如果出错，就不在进行处理
   	Alert("aaa");//*/
   	return;
	}
	
	//trade.Buy(1.23,symbol1);
	//trade.Buy(2,34,symbol2);
	//fatalerror = true;
	//return ;
	datetime tm[1],othertm[1];
	if(CopyTime(Symbol(),Period(),0,1,tm)<=0)return; //当前所在bar的时间
   if(CopyTime(othersymbol,Period(),0,1,othertm)<=0)return; //当前所在bar的时间
   
   if(tm[0]!=othertm[0])
   {
   	return;//,不在一个bar上面，等同在bar再处理
   }
   //同在一个bar了
   MqlTick last_tick,other_last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick)||!SymbolInfoTick(othersymbol,other_last_tick))
   {
   	return ;//获得最新tick出现错误。
   }
   //获得了最新的各自的tick
   //如果两个tick之间的时间差超过2s，说明很可能交易非常少，或者就是有一个不在交易时间内了
   if(MathAbs(last_tick.time_msc-other_last_tick.time_msc) > 2000)
   {
   	return ;
   }
   //两个tick的时间足够接近了
   //判断当前tick的价差的威廉水平
   double heldg_william[1];
   if(CopyBuffer(ewillam_heldg_handle,0,0,1,heldg_william)<=0)
   {//找不到当前的指标值
   	return;
   }
   int dir = 0;   //开多 1开多，-1，开空，0，无方向
   int level = 0; //对应等级
   
   //获得当前的值对应的等级
   //static int opendir = 0;
   static int openlevel = 0;
   static int closedir = 0;
   static int closelevel = 0;
   static int maxdir = 0;
   //static int maxlevel = 0;  // 用来判断能否入场、加仓的值，如果跳若干个级才能入场或者加仓mode1不支持
   
   static int empty_max = 0; // 空仓时指标最大去到的等级。（由-10 -- 10，0为无方向）
   static int empty_min = 0;
   static int cumlevel = 0 ; //当前累加等级，用来在入场和加仓的时候寻找入场的手数 
   static double cumvol_1 = 0.0;
   static double cumvol_2 = 0.0;
   static double lastprofit_pershard = 0.0;//最近一次入场、加仓时的总亏损程度 
   static double lastprofit_permul = 0.0;
   Judge_Level(dir,level,heldg_william[0]);
   static datetime opentime;
   static int openmaxlevel = 0;
   static double openmaxloss = 0;
   
   
   //double vol1,vol2,profit1,profit2;
   double totalprofit ;//= profit1 + profit2;
   double totalvol 	 ;//= cumvol_1 + cumvol_2;
   int dir1,dir2;
   FindProfit_Vol(totalprofit,totalvol);
   if(MathAbs(cumvol_1 +cumvol_2 - totalvol) >0.000001 )
   {
   	//实际持仓跟计算持仓不一致，
   	Alert("The Position is not correct! cumvol_1:",cumvol_1,"  vumvol_2:",cumvol_2,"  total:",totalvol);
   	
   	fatalerror = true;
   	return ;
   }
  	
   //Print("profit_per_shard:",totalvol>0.000001?totalprofit / totalvol:0,", lastprofit_pershard:",lastprofit_pershard);
   
   
   if(cumvol_1 <  0.000001)//查看是否为空仓
   {
   	//判断并更新当前的最大等级
   	
   	//查看是否等开仓
   	
   	if(level*dir-empty_min >= dif_level && dir >0) // 达到做多的条件
   	{
   		
   		double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   		double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   		//进场做多，
   		string  comment= "做多等级"+IntegerToString(cumlevel+1)+";累计收益：0.0";
   		if(!trade.Buy(v1,symbol1,0,0,0,comment))
   		{
   			Alert("can't open long position",symbol1);
   			return ;
   		}
   		if(!trade.Buy(v2,symbol2,0,0,0,comment))
   		{
   			Alert("can't open long position",symbol2);
   			trade.PositionClose(symbol1);//如果这个没法开仓，但是上一个已经开仓了，所以要平掉
   			//并且要设置当前为错误的状态
   			fatalerror =true;
   			return ;
   		}
   		
   		opendir = dir;
   		openlevel = level;
   		cumvol_1 = v1;
   		cumvol_2 = v2;
   		lastprofit_pershard = 0.0;
   		lastprofit_permul = 0.0 ;
   		opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   		openmaxlevel = level;
   		openmaxloss = 0.0;
   		cumlevel ++;
   	}
   	else if(empty_max - level*dir >=dif_level && dir < 0 ) //达到做空的条件
   	{
   		
   		//进场做空，
   		double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   		double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   		string  comment= "做空等级"+IntegerToString(cumlevel+1)+";累计收益：0.0";
   		if(!trade.Sell(v1,symbol1,0,0,0,comment))
   		{
   			Alert("can't open short position",symbol1);
   			return ;
   		}
   		if(!trade.Sell(v2,symbol2,0,0,0,comment))
   		{
   			Alert("can't open short position",symbol2);
   			trade.PositionClose(symbol1);//如果这个没法开仓，但是上一个已经开仓了，所以要平掉
   			//并且要设置当前为错误的状态
   			fatalerror =true;
   			return ;
   		}
   		
   		opendir = dir;
   		openlevel = level;
   		cumvol_1 = v1;
   		cumvol_2 = v2;
   		lastprofit_pershard = 0.0;
   		lastprofit_permul = 0.0 ;
   		opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   		openmaxlevel = level;
   		openmaxloss = 0.0;
   		cumlevel ++;
   	}
   	else
   	{//既不做多，也不做空，那就更新空仓的信息
   	empty_max = MathMax(empty_max,level*dir);
   	empty_min = MathMin(empty_min,level*dir);
   	return;
   	//空仓，但是什么条件都不符合，不return也是应该没有代码要执行了
   	}
   }
   else
   {
      double profit_per_mul = totalprofit / multi2[cumlevel-1];//每基准倍数盈利情况
   	double profit_per_shard = totalprofit / totalvol;
   	//有仓位了，那么就要判断是否要加仓或者是离场了
   	//首先判断收益是否达到可以离场的条件了
   	//获得账户的盈利情况并计算平均没有盈利
   	
   	if(opendir != dir) //方向已经发生改变，那么就可以判断是否可以平仓了
      {
         
   	   //有仓位了，那么就要判断是否要加仓或者是离场了
   	   //首先判断收益是否达到可以离场的条件了
   	   //获得账户的盈利情况并计算平均没有盈利
      	
   	   //if(profit_per_shard>profit_target2||
   	   //	((profit_per_shard>profit_target1||level>=sl_level)&&dir!=opendir))//可以离场了
         if(level > 0  || //达到强超不管是否盈利均要出场
            (level == 0 && profit_per_mul > profit_target1 ) || //达到弱超，每基础倍数盈利达到目标1
            (level < 0 && profit_per_mul > profit_target2 ))    //达到强超，每基础倍数盈利达到目标2
            //可以离场了
   	   {
   		   /*bool res1 = trade.PositionClose(symbol1);
   		   bool res2 = trade.PositionClose(symbol2);
   		   if(!(res1 && res2))
   		   {
   			   Alert("Error in PositionClose: ",res1,res2);
   			   fatalerror = true;
   			   return ;
   		   }
   		   */
   		   PositionCloseAll();
      		
      		
   		   closedir = dir;
   		   closelevel = level;
   		   cumlevel = 0;
   		   cumvol_1 = 0.0;
   		   cumvol_2 = 0.0;
   		   empty_max = dir * level;
   		   empty_min = dir * level;
   		   lastprofit_pershard = 0.0;
   		   lastprofit_permul = 0.0;
   		   opentime = 0;
   		   openmaxlevel = 0;
   		   openmaxloss = 0.0;
   		   	
   	   }
   	   return;
   	}
   		
   		
   	
   	
   	//判断是否要加仓
   	if(( MathMax(last_tick.time,other_last_tick.time)-opentime) < min_interval)
   	{//小于最小间隔时间，只记录当前的最大记录
   		if(dir == opendir && level > openlevel)
   		{
   			
   			openmaxlevel = MathMax(level,openmaxlevel);//记录间隔时间内的最大同向偏离等级。
   			
   		}
   		openmaxloss = MathMin(openmaxloss,profit_per_mul);//记录间隔时间内的最大亏损
   		return; //仅记录，不处理
   	
   	}
   	//超出最小加仓间隔的了，可以考虑加仓
   	if(opendir == dir && level > openlevel && level >=openmaxlevel && profit_per_mul <= openmaxloss)//达到加仓的条件(1.同向, 2，越级，3超出间隔时间内的最大级)
   	{
   		//根据当前的cumlevel来加仓
   		if(dir >0)
   		{//加仓多
   			//进场做多，未完成
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做多等级"+IntegerToString(cumlevel+1)+";累计收益mul："+DoubleToString(profit_per_mul)+",shard:"+DoubleToString(profit_per_shard);
   			if(!trade.Buy(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol1);
   				return ;
   			}
   			if(!trade.Buy(v2,symbol2,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol2);
   				//trade.Sell(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; 
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_permul;
   			
   			cumlevel ++;
   		}
   		if(dir<0)
   		{//加仓空
   			//进场做空，
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做空等级"+IntegerToString(cumlevel+1)+";累计收益mul："+DoubleToString(profit_per_mul)+",shard:"+DoubleToString(profit_per_shard);
   			if(!trade.Sell(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add short position",symbol1);
   				return ;
   			}
   			if(!trade.Sell(v2,symbol2,0,0,0,comment))
   			{
   				Alert("can't add short position",symbol2);
   				//trade.Buy(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; 
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_permul;
   			cumlevel ++;
   		}
   		
   		//opendir = dir;
   		//openlevel = level;
   		//cumlevel ++;
   		return ;
   	}
   	//如果已经达到最最大级别就是0-0.03，和0.97-1时，按照每手亏损情况来加仓。
   	if(level ==openlevel && level == max_level && cumlevel < totallevel)//当达到极端的情况是
   	{
   		//获得账户的亏损情况，计算每手亏损，然后根据cumlevel来，计算加仓阈值，然后判断当前每手亏损是否已经达到了这个阈值
   		if((lastprofit_permul-profit_per_mul)<add_lost_permul || profit_per_mul > openmaxloss) //亏损使用负数来表示的lastprofit_pershard > openmaxloss就是当前的亏损要比间隔时间内的亏损要少，那就不考虑了
   		{//加仓后亏损没有再次拉大到add_lost_pershard               或者  亏损没有达到间隔时间的最大亏损
   			//没有达到加仓的条件
   			return;
   			
   		}
   		//相比上一次加仓的每手亏损，此次每手亏损超出了加仓的阈值，可加仓
   		//根据当前的cumlevel来加仓，未完成
   		if(dir >0)
   		{//加仓多
   			//进场做多，未完成
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做多等级"+IntegerToString(cumlevel+1)+";累计收益mul："+DoubleToString(profit_per_mul)+",shard:"+DoubleToString(profit_per_shard);
   			if(!trade.Buy(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol1);
   				return ;
   			}
   			if(!trade.Buy(v2,symbol2,0,0,0,comment))
   			{
	   			Alert("can't add long position",symbol2);
   				//trade.Sell(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel];
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_permul;
   			cumlevel ++;
   		}
   		if(dir<0)
   		{//加仓空
   			//进场做空，
   			double v1 = NormalizeDouble(the_lots_1*multi[cumlevel],minorderdigits);
   			double v2 = NormalizeDouble(the_lots_2*multi[cumlevel],minorderdigits);
   			string  comment= "做空等级"+IntegerToString(cumlevel+1)+";累计收益mul："+DoubleToString(profit_per_mul)+",shard:"+DoubleToString(profit_per_shard);
   			if(!trade.Sell(v1,symbol1,0,0,0,comment))
   			{
	   			Alert("can't add short position",symbol1);
   				return ;
   			}
   			if(!trade.Sell(v2,symbol2,0,0,0,comment))
   			{
   				Alert("can't add short position",symbol2);
   				trade.Buy(v1,symbol1,0,0,0,comment);//如果这个没法加仓，但是上一个已经加仓了，所以要平掉
   				//并且要设置当前为错误的状态
   				fatalerror =true;
   				return ;
   			}
   		
   			opendir = dir;
   			openlevel = level;
   			cumvol_1 += v1;
   			cumvol_2 += v2;
   			lastprofit_pershard = totalprofit/(cumvol_1 + cumvol_2); //入场后，每手亏损的情况会得到减弱
   			lastprofit_permul = totalprofit/multi2[cumlevel]; 
   			opentime = MathMax(last_tick.time,other_last_tick.time);//设置开仓点；
   			openmaxlevel = level;
   			openmaxloss = lastprofit_permul;
   			cumlevel ++;
   		}
   		return;
   	}
   	//什么也没有，return不return都可以了
   	return;
   }
}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
