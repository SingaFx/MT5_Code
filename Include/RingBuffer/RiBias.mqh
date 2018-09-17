//+------------------------------------------------------------------+
//|                                                       RiBias.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include "RiBuffDbl.mqh"

class CRiBias:public CRiBuffDbl
   {
private:
   double        sum_price;
protected:
   virtual void  OnAddValue(double value);
   virtual void  OnRemoveValue(double value);
   virtual void  OnChangeValue(int index, double del_value, double new_value);
public:
                 CRiBias(void){sum_price=0;};
   
   double        Bias(void);
   
   };
void CRiBias::OnAddValue(double value)
   {
    sum_price+=value;
   }
void CRiBias::OnRemoveValue(double value)
   {
    sum_price-=value;
   }
void CRiBias::OnChangeValue(int index,double del_value,double new_value)
   {
    sum_price+=new_value;
    sum_price-=del_value;
   }
double CRiBias::Bias(void)
   {
    return (GetValue(GetTotal()-1)-sum_price/GetTotal())/(sum_price/GetTotal())*100;
   }