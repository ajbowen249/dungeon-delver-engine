21 cs$ = "COM:88N1E"
23 sa% = -22272
50 ad% = sa%
60 open cs$ for input as 1
100 c$ = input$(1,1)
120 if c$ <> ":" then goto 100
130 gosub 1000
140 bc% = va%
141 print ""
142 print bc%;" ";
143 if bc% = 0 then goto 300
160 gosub 1000
170 gosub 1000
180 gosub 1000
190 for b% = 1 to bc%
200   gosub 1000
201   print ".";
210   poke ad%, va%
220   ad% = ad% + 1
240 next b%
250 gosub 1000
270 goto 100
300 print "done"
305 close 1
310 end
1000 c$ = input$(1,1)
1020 gosub 2000
1030 va% = (dv% * 16)
1040 c$ = input$(1,1)
1050 gosub 2000
1060 va% = va% + dv%
1070 return
2000 v% = asc(c$)
2030 if v% <= 57 then dv% = v% - 48 else dv% = (v% - 65) + 10
2040 return
