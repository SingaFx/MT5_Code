//+------------------------------------------------------------------+
//|                                              StrategyFactory.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"

/*
   GetStrategy is a factory of strategies. It creates a strategy object corresponding to a certain name.
   The method is included in a separate file for automation purposes.
*/

#include <Strategy\Strategy.mqh>
#include <Strategy\Samples\MovingAverage.mqh>
#include <Strategy\Samples\ChannelSample.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy *CStrategy::GetStrategy(string name)
  {
   if(name=="MovingAverage")
      return new CMovingAverage();
   if(name=="BollingerBands")
      return new CChannel();
   CLog *mlog=CLog::GetLog();
   string text="Strategy with name "+name+" not defined in GetStrategy method. Please define strategy in 'StrategyFactory.mqh'";
   CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
   mlog.AddMessage(msg);
   return NULL;
  }
//+------------------------------------------------------------------+
