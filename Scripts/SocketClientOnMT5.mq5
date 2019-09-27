//+------------------------------------------------------------------+
//|                                           scOnTickMarketWatch.mq5|
//|                                             Copyright 2019, IDTU |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, IDTU"
#property version   "1.00"


//socket数据发送函数
bool socksend(int sock,string request) 
{
   char req[];
   int  len=StringToCharArray(request,req)-1;
   if(len<0) return(false);
   return(SocketSend(sock,req,len)==len); 
}

//启动事件函数
void OnStart()
{
   long new_tick_time[];   
   long last_tick_time[];
   ushort po = 0;
   MqlTick new_tick;
   string symbols[];
   
   MqlRates bars[2];
   long new_bar_time[];
   long last_bar_time[];
   ENUM_TIMEFRAMES period[8] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};
   
   //存储发送数据的字符串变量
   string tosend_tick;
   string tosend_bar;
   int socket;
   
   long count = 0; //测试计数器
   
   //获取品种数量和名称
   int total = SymbolsTotal(true);
   ArrayResize(new_tick_time, total);
   ArrayResize(new_bar_time, total);
   ArrayResize(last_tick_time, total);
   ArrayResize(last_bar_time, total);
   ArrayResize(symbols, total);
   for(ushort pos=0; pos<total; pos++)
   {  
      symbols[pos]=SymbolName(pos,true);
      
   }
   
   //初始化时间数组
   ArrayInitialize(last_tick_time, 0);
   ArrayInitialize(last_bar_time, 0);
   
   socket=SocketCreate();
   int socket_statu = SocketConnect(socket,"127.0.0.1",21567,1000);
   //监测ticks变动
   while(!_StopFlag)
   {  
      for(int i=0; i<SymbolsTotal(true); i++)  //遍历每个品种
      {
         SymbolInfoTick(symbols[i],new_tick);   
         new_tick_time[i] = new_tick.time_msc; //获取品种价格变动的最新时间，以毫秒计
         if(new_tick_time[i]>last_tick_time[i])  //如果最新时间大于上次变动时间，表明有价格变动
         {  

            //在MT5中打印数据信息            
            //Print( " New tick on the symbol ", symbols[i], " ",new_tick_time[i]);
            
            if(socket!=INVALID_HANDLE)
            {  
               if(socket_statu)
               {
                  tosend_tick = "tick" + " " + (string)new_tick.time_msc + " " + symbols[i] + " " 
                                 + (string)new_tick.ask + " " + (string)new_tick.bid; //将数据组装成字符串  
                  string sendbuf_tick = IntegerToString(StringLen(tosend_tick),4) + tosend_tick;  //前4位存储数据字符串的长度信息   
                  bool send_statu = socksend(socket, sendbuf_tick);  //发送数据
                  if(!send_statu)   //如果发送失败，将失败信息写入日志
                  {  
                     int filehandle = FileOpen("send_faild_log.txt",FILE_WRITE|FILE_TXT);
                     FileWrite(filehandle, new_tick.time_msc, symbols[i]);
                  }
                  //count++;  //统计发送数据条数
                  //Print(count);
               }      
               else Print("Connection ","",":",21567," error ",GetLastError());
            }
            else Print("socket invalid");
            last_tick_time[i] = new_tick_time[i];  //更新价格变动时间
         }      
         
         for(int j=0; j<8; j++)  //8个不同周期的bar
         {
            CopyRates(symbols[i],period[j],0,2,bars);
            if(bars[1].time > last_bar_time[i])
            {
               //Print( " New bar on the symbol ", symbols[i], " ", bars[0].time);
               if(socket!=INVALID_HANDLE)
               {  
                  if(socket_statu)
                  { 
                     long bar_time_msc = bars[0].time * 1000;  //将datetime转化为long型时间戳
                     tosend_bar = EnumToString(period[j]) + " " + (string)bar_time_msc + " " + symbols[i] + " " + (string)bars[0].open + " "
                                    + (string)bars[0].high + " " + (string)bars[0].low + " " + (string)bars[0].close;
                     string sendbuf_bar = IntegerToString(StringLen(tosend_bar),4) + tosend_bar; 
                     bool send_statu = socksend(socket, sendbuf_bar);
                     if(!send_statu)   //如果发送失败，将失败信息写入日志
                     {  
                        int filehandle = FileOpen("send_faild_log.txt",FILE_WRITE|FILE_TXT);
                        FileWrite(filehandle, bars[0].time, symbols[i]);
                     }
                  }
                  else Print("Connection ","",":",21567," error ",GetLastError());
               }
               else Print("socket invalid");
               last_bar_time[i] = bars[1].time;
            }
         }
      }
   }
   SocketClose(socket); //关闭套接字   
}
