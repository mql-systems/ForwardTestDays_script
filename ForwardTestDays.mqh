//+------------------------------------------------------------------+
//|                                              ForwardTestDays.mqh |
//|                            Copyright 2022. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+

//--- inputs
input datetime i_DtTestFrom   = __DATE__-10368000; // Test from
input datetime i_DtTestTo     = __DATE__;          // Test to
input int      i_GenerateDays = 30;                // Generate days (min 10)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   //--- check inputs
   if (i_DtTestFrom >= i_DtTestTo)
   {
      Alert("Error: Incorrect time interval");
      return;
   }
   
   if ((i_DtTestTo-i_DtTestFrom) < 2592000) // 2592000 == 30 days
   {
      Alert("Error: The minimum test period is 60 working days");
      return;
   }
   
   if (i_GenerateDays < 10)
   {
      Alert("Error: The minimum number of test days is 10");
      return;
   }
   
   int intervalDays = (int)MathFloor((i_DtTestTo-i_DtTestFrom)/86400);
   if (intervalDays < i_GenerateDays*2)
   {
      Alert("Error: The interval should be twice as long as the number of days tested");
      return;
   }
   
   //--- generate random days
   MathSrand(GetTickCount());
   int days[];
   if (ArrayResize(days, i_GenerateDays) == -1)
   {
      Alert("Error: Creating an array for random days");
      return;
   }
   
   int i;
   for (i=0; i<i_GenerateDays; i++)
      days[i] = MathRandomBounds(1, intervalDays);
   if (! ArraySort(days))
   {
      Alert("Error: Sorting an array of random days");
      return;
   }
   
   // TODO: Check and replace recurring and non-working days
   
   //--- create csv file
   string filename = "ForwardTestDays_"+TimeToString(i_DtTestFrom,TIME_DATE)+"_"+TimeToString(i_DtTestTo,TIME_DATE)+"_"+IntegerToString(TimeCurrent())+".csv";
   FileDelete(filename);
   int fileHandle = FileOpen(filename,FILE_WRITE|FILE_CSV);
   if (fileHandle == INVALID_HANDLE)
   {
      Alert("Error: Creating file "+filename);
      return;
   }
   
   //--- save random days
   FileWrite(fileHandle, "Date", "Result (+)", "Result (-)", "Comments");
   for (i=0; i<i_GenerateDays; i++)
      FileWrite(fileHandle, TimeToString(i_DtTestFrom+(days[i]*86400),TIME_DATE));
   
   FileClose(fileHandle);
   
   //--- success
   Alert("Success");
}

//+------------------------------------------------------------------+
//| Random integer from-to                                           |
//+------------------------------------------------------------------+
int MathRandomBounds(int minVal, int maxVal)
{
   return int(minVal + MathRound((maxVal - minVal) * (MathRand() / 32767.0)));
}

//+------------------------------------------------------------------+
