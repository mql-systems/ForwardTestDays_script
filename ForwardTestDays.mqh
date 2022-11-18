//+------------------------------------------------------------------+
//|                                              ForwardTestDays.mqh |
//|                            Copyright 2022. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+

//--- inputs
input datetime i_DtTestFrom   = __DATE__-10368000; // Test from
input datetime i_DtTestTo     = __DATE__;          // Test to
input int      i_GenerateDays = 30;                // Generate days (min 10)

//--- global variables
int g_IntervalDaysCnt;
int g_Days[];

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
   
   g_IntervalDaysCnt = (int)MathFloor((i_DtTestTo-i_DtTestFrom)/86400);
   if (g_IntervalDaysCnt < i_GenerateDays*2)
   {
      Alert("Error: The interval should be twice as long as the number of days tested");
      return;
   }
   
   //--- generate random days
   MathSrand(GetTickCount());
   if (! GenerateRandomDays())
      return;
   
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
   for (int i=0; i<i_GenerateDays; i++)
      FileWrite(fileHandle, TimeToString(i_DtTestFrom+(g_Days[i]*86400),TIME_DATE));
   
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
//| Generate random days                                             |
//+------------------------------------------------------------------+
bool GenerateRandomDays()
{
   int intervalDays[];
   if (ArrayResize(g_Days, i_GenerateDays) == -1 || ArrayResize(intervalDays, g_IntervalDaysCnt) == -1)
   {
      Alert("Error: Creating an array for random days");
      return false;
   }
   
   int i, randDay, checkWeek;
   int intervalDaysMark = g_IntervalDaysCnt-1;
   int allDaysCnt = (int)MathFloor(i_DtTestTo/86400);
   
   intervalDays[0] = g_IntervalDaysCnt;
   for (i=1; i<g_IntervalDaysCnt; i++)
      intervalDays[i] = i;
   
   for (i=0; i<i_GenerateDays; i++)
   {
      randDay = MathRandomBounds(0, intervalDaysMark);
      g_Days[i] = intervalDays[randDay];
      intervalDays[randDay] = intervalDays[intervalDaysMark--];
      checkWeek = (int)MathMod(allDaysCnt+g_Days[i], 7);
      if (checkWeek == 3 || checkWeek == 4)
         i--;
   }
   
   ArraySort(g_Days);
   
   return true;
}

//+------------------------------------------------------------------+
