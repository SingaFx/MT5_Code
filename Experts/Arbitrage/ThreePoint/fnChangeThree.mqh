//меняем расположение пар в треугольниках для более удобного последующего использования   

#include "head.mqh"

void fnChangeThree(stThree &MxSmb[])
   {
      int count=0;
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {//for         
         // сначала определимся что стоит на третьем месте
         // на 3 месте стоит та пара, базовая валюта которой не совпадает с двумя другими базовыми валютами
         string sm1base="",sm2base="",sm3base="";
         
         // если вдруг почему то не смогли получить базовую валюту, то данный треугольник не используем в работе
         if(!SymbolInfoString(MxSmb[i].smb1.name,SYMBOL_CURRENCY_BASE,sm1base) ||
         !SymbolInfoString(MxSmb[i].smb2.name,SYMBOL_CURRENCY_BASE,sm2base) ||
         !SymbolInfoString(MxSmb[i].smb3.name,SYMBOL_CURRENCY_BASE,sm3base)) {MxSmb[i].smb1.name="";continue;}
                  
         // если базовая валюта 1 и 2 символа совпадают то данный шаг пропускаем, если же нет то меняем местами пары
         if(sm1base!=sm2base)
         {         
            if(sm1base==sm3base)
            {
               string temp=MxSmb[i].smb2.name;
               MxSmb[i].smb2.name=MxSmb[i].smb3.name;
               MxSmb[i].smb3.name=temp;
            }
            
            if(sm2base==sm3base)
            {
               string temp=MxSmb[i].smb1.name;
               MxSmb[i].smb1.name=MxSmb[i].smb3.name;
               MxSmb[i].smb3.name=temp;
            }
         }
         
         //теперь определим первое и второе место
         //на втором месте стоит та пара, валюта прибыли у которой совпадает с валютой базой у третьей. 
         //в таком случае мы всегда используем умножение
         sm3base=SymbolInfoString(MxSmb[i].smb3.name,SYMBOL_CURRENCY_BASE);
         string sm2prft=SymbolInfoString(MxSmb[i].smb2.name,SYMBOL_CURRENCY_PROFIT);
         
         // меняем первую и вторую пару местами
         if(sm3base!=sm2prft)
         {
            string temp=MxSmb[i].smb1.name;
            MxSmb[i].smb1.name=MxSmb[i].smb2.name;
            MxSmb[i].smb2.name=temp;
         }
         
         // отпринтовали об обработанном треугольнике
         Print("Use triangle: "+MxSmb[i].smb1.name+" + "+MxSmb[i].smb2.name+" + "+MxSmb[i].smb3.name);
         count++;
      }//for
      // сообщаем об общем количестве треугольников в работе
      Print("All used triangles: "+(string)count);
   }
