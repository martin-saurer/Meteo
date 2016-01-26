NB. ****************************************************************************
NB. File:        meteo.ijs
NB. Author:      Martin Saurer, 02.10.2013
NB. Description: Various visulaization of swiss weather data
NB.              (rain & temperature) 1864-2013.
NB. License:     GPL Version 3.
NB.
NB. Youtube:     http://www.youtube.com/playlist?list=PLLcTTp6EQ_egylIerYEjCBbEVhnPzSdXP
NB. ****************************************************************************

NB. Required library scripts
require 'tables/dsv'
require 'graphics/plot'
require 'jzplot'

NB. Read and format raw data, provide filter scripts
data =: ('|';'') readdsv jpath '~user/Meteo/RegenTemp_1864-2013.txt'
data =: (I. (<'PAY') i. 0{|:data){data NB. Remove PAY (no data)
stat =: ('|';'') readdsv jpath '~user/Meteo/Legende_Stationen.txt'
keys =: (2,$(~.0{|:data))$(~.0{|:data),(I.((1}.0{|:stat)e.(~.0{|:data))){1}.1{|:stat
chop =: 4 : '(y#i.#y)</.x'
spym =: |: ((#data),2) $ (,/>1{|:data) chop ((2*#data) $ 4 2)
data =: (0{|:data),.(0{spym),.(1{spym),.(". each 2{|:data),.(". each 3{|:data)
desc =: 3 : '>(I. (<y) E. 0{keys) { 1{keys'
gets =: 4 : '(I. (<y) E. 0{|:x){x'
gety =: 4 : '(I. (<y) E. 1{|:x){x'
getm =: 4 : '(I. (<y) E. 2{|:x){x'
vfmx =: 3 : '}:(,|."1 [ 1,.-. *./\"1 |."1 y='' '')#,y,.LF'
mons =: '<All>';'Januar';'Februar';'März';'April';'Mai';'Juni';'Juli';'August';'September';'Oktober';'November';'Dezember'
yeal =: ": (".>1{0{data)+10*i.1+(>.(((".>1{0{_1{.data)-(".>1{0{data))%10))
yeax =: ": i. # ". yeal
monl =: 'Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez'
monx =: ": i. 12
xtin =: ":((i.16)*((#(data gets >0{0{keys))%15))
xlan =: yeal
xtit =: ":((i.16)*((#(data gets >0{0{keys))%15))
xlat =: yeal
nied =: ,/>3{|:(data gets >0{0{keys)
temp =: ,/>4{|:(data gets >0{0{keys)
lreg =: 4 : 'y %. 1 ,. x'
nreg =: ((1{((i.#nied) lreg nied))*(i.#nied))+(0{((i.#nied) lreg nied))
treg =: ((1{((i.#temp) lreg temp))*(i.#temp))+(0{((i.#temp) lreg temp))
ni3d =: (150,12)$,/>3{|:(data gets >0{0{keys)
te3d =: (150,12)$,/>4{|:(data gets >0{0{keys)
vpox =: 2.8
vpoy =: _4
vpoz =: 2.4

NB. GUI
meteo_win =: 0 : 0
   pc meteo nosize;
   pn Schweizer Wetterdaten (Niederschlag/Temperatur) 1864-2013;
   bin v g;
      grid cell 0 0;
      cc lab1 static right; cn Wetterstation:;
      grid cell 0 1;
      cc stasel combolist;
      grid cell 0 2;
      cc lab2 static right; cn Jahr:;
      grid cell 0 3;
      cc yeasel combolist;
      grid cell 0 4;
      cc lab3 static right; cn Monat:;
      grid cell 0 5;
      cc monsel combolist;
   bin z g;
      grid cell 0 0 1 1; minwh 642 400;
      cc img1 image;
      grid cell 0 1;
      cc tdtd tab;
      tabnew 2D;
      bin g;
         grid cell 0 0;
         cc lab4 static; cn Niederschlag (mm);
         grid cell 1 0; minwh 420 150;
         cc isi1 isigraph flush;
         grid cell 2 0; minwh 420 10;
         cc spa1 static; cn " ";
         grid cell 3 0;
         cc lab5 static; cn Temperatur (°C);
         grid cell 4 0; minwh 420 150;
         cc isi2 isigraph;
      tabnew 3D (Niederschlag);
      bin g;
         grid cell 0 0 1 7;
         cc isi3 isigraph;
         grid cell 1 0;
         cc but1a button; cn X+;
         grid cell 1 1;
         cc but2a button; cn X-;
         grid cell 1 2;
         cc but3a button; cn Y+;
         grid cell 1 3;
         cc butra button; cn Reset;
         grid cell 1 4;
         cc but4a button; cn Y-;
         grid cell 1 5;
         cc but5a button; cn Z+;
         grid cell 1 6;
         cc but6a button; cn Z-;
      tabnew 3D (Temperatur);
      bin g;
         grid cell 0 0 1 7;
         cc isi4 isigraph;
         grid cell 1 0;
         cc but1b button; cn X+;
         grid cell 1 1;
         cc but2b button; cn X-;
         grid cell 1 2;
         cc but3b button; cn Y+;
         grid cell 1 3;
         cc butrb button; cn Reset;
         grid cell 1 4;
         cc but4b button; cn Y-;
         grid cell 1 5;
         cc but5b button; cn Z+;
         grid cell 1 6;
         cc but6b button; cn Z-;
      tabend;
)

meteo_run =: 3 : 0
   showevents_jqtide_ 0
   wd 'reset'
   wd meteo_win

   if. (#ARGV_z_) > 1 do.
      wd 'ide hide'
   end.

   wd 'set stasel items ',vfmx > 1{keys
   wd 'set yeasel items ',vfmx > '<All>';~.1{|:data
   wd 'set monsel items ',vfmx > mons
   wd 'set img1   image ',jpath '~user/Meteo/Schweiz_',(>0{0{keys),'.png'

   isi1 =: ('meteo';'isi1') conew 'jzplot'
   isi2 =: ('meteo';'isi2') conew 'jzplot'
   isi3 =: ('meteo';'isi3') conew 'jzplot'
   isi4 =: ('meteo';'isi4') conew 'jzplot'

   pd__isi1 1 2 3
   pd__isi2 1 2 3
   pd__isi3 1 2 3
   pd__isi4 1 2 3

   wd 'pcenter'
   wd 'pshow'

   meteo_update''
)

meteo_stasel_select =: 3 : 0
   meteo_update''
)

meteo_yeasel_select =: 3 : 0
   meteo_update''
)

meteo_monsel_select =: 3 : 0
   meteo_update''
)

meteo_tdtd_select =: 3 : 0
   meteo_isi1_update''
   meteo_isi2_update''
   meteo_isi3_update''
   meteo_isi4_update''
   0
)

meteo_update =: 3 : 0
   s =. getval 'stasel'
   y =. getval 'yeasel'
   m =. getval 'monsel'
   d =. data
   s =. 0{>((I.(<s)E.(1{keys)){(0{keys))
   d =. d gets s
   wd 'set img1 image ',jpath ('~user/Meteo/Schweiz_',s,'.png')
   if. '<All>' -: y do.
      if. '<All>' -: m do.
         xtin =: ":((i.16)*((#d)%15))
         xlan =: yeal
         xtit =: ":((i.16)*((#d)%15))
         xlat =: yeal
      else.
         m =. _2{.('0',":(I.(<m)E.mons))
         d =. d getm m
         xtin =: ":((i.16)*((#d)%15))
         xlan =: yeal
         xtit =: ":((i.16)*((#d)%15))
         xlat =: yeal
      end.
   else.
      d =. d gety y
      if. '<All>' -: m do.
         xtin =: monx
         xlan =: monl
         xtit =: monx
         xlat =: monl
      else.
         m =. _2{.('0',":(I.(<m)E.mons))
         d =. d getm m
         xtin =: ''
         xlan =: ''
         xtit =: ''
         xlat =: ''
      end.
   end.
   nied =: ,/>3{|:d
   temp =: ,/>4{|:d
   ni3d =: (150,12)$,/>3{|:(data gets s)
   te3d =: (150,12)$,/>4{|:(data gets s)
   try.
      nreg =: ((1{((i.#nied) lreg nied))*(i.#nied))+(0{((i.#nied) lreg nied))
      treg =: ((1{((i.#temp) lreg temp))*(i.#temp))+(0{((i.#temp) lreg temp))
   catch.
      nreg =: 0
      treg =: 0
   end.
   meteo_isi1_update''
   meteo_isi2_update''
   meteo_isi3_update''
   meteo_isi4_update''
)

meteo_isi1_update =: 3 : 0
   pd__isi1 'reset'
   if. -. '' -: xtin do.
      pd__isi1 'xticpos ',xtin
      pd__isi1 'xlabel  ',xlan
   end.
   if. 1 -: #nied do.
      pd__isi1 'type bar'
   end.
   pd__isi1 nied
   pd__isi1 nreg
   pd__isi1 'show'
)

meteo_isi2_update =: 3 : 0
   pd__isi2 'reset'
   if. -. '' -: xtit do.
      pd__isi2 'xticpos ',xtit
      pd__isi2 'xlabel  ',xlat
   end.
   if. 1 -: #temp do.
      pd__isi2 'type bar'
   end.
   pd__isi2 temp
   pd__isi2 treg
   pd__isi2 'show'
)

meteo_isi3_update =: 3 : 0
   pd__isi3 'reset'
   pd__isi3 'yticpos ',monx
   pd__isi3 'ylabel ',monl
   pd__isi3 'xticpos ',":((i.16)*((#ni3d)%15))
   pd__isi3 'xlabel ',yeal
   pd__isi3 'type surface'
   pd__isi3 'backcolor black'
   pd__isi3 'axiscolor white'
   pd__isi3 'labelcolor white'
   pd__isi3 'bandcolor |.bgclr'
   pd__isi3 'viewpoint ',":(vpox,vpoy,vpoz)
   pd__isi3 ni3d
   pd__isi3 'show'
)

meteo_isi4_update =: 3 : 0
   pd__isi4 'reset'
   pd__isi4 'yticpos ',monx
   pd__isi4 'ylabel ',monl
   pd__isi4 'xticpos ',":((i.16)*((#te3d)%15))
   pd__isi4 'xlabel ',yeal
   pd__isi4 'type surface'
   pd__isi4 'backcolor black'
   pd__isi4 'axiscolor white'
   pd__isi4 'labelcolor white'
   pd__isi4 'viewpoint ',":(vpox,vpoy,vpoz)
   pd__isi4 te3d
   pd__isi4 'show'
)

meteo_but1a_button =: 3 : 0
   vpox =: vpox + 0.2
   meteo_isi3_update''
)

meteo_but2a_button =: 3 : 0
   vpox =: vpox - 0.2
   meteo_isi3_update''
)

meteo_but3a_button =: 3 : 0
   vpoy =: vpoy + 0.2
   meteo_isi3_update''
)

meteo_but4a_button =: 3 : 0
   vpoy =: vpoy - 0.2
   meteo_isi3_update''
)

meteo_but5a_button =: 3 : 0
   vpoz =: vpoz + 0.2
   meteo_isi3_update''
)

meteo_but6a_button =: 3 : 0
   vpoz =: vpoz - 0.2
   meteo_isi3_update''
)

meteo_butra_button =: 3 : 0
   vpox =: 2.8
   vpoy =: _4
   vpoz =: 2.4
   meteo_isi3_update''
)

meteo_but1b_button =: 3 : 0
   vpox =: vpox + 0.2
   meteo_isi4_update''
)

meteo_but2b_button =: 3 : 0
   vpox =: vpox - 0.2
   meteo_isi4_update''
)

meteo_but3b_button =: 3 : 0
   vpoy =: vpoy + 0.2
   meteo_isi4_update''
)

meteo_but4b_button =: 3 : 0
   vpoy =: vpoy - 0.2
   meteo_isi4_update''
)

meteo_but5b_button =: 3 : 0
   vpoz =: vpoz + 0.2
   meteo_isi4_update''
)

meteo_but6b_button =: 3 : 0
   vpoz =: vpoz - 0.2
   meteo_isi4_update''
)

meteo_butrb_button =: 3 : 0
   vpox =: 2.8
   vpoy =: _4
   vpoz =: 2.4
   meteo_isi4_update''
)

meteo_close =: 3 : 0
   wd 'pclose'
   destroy__isi1''
   destroy__isi2''
   destroy__isi3''
   destroy__isi4''

   if. (#ARGV_z_) > 1 do.
      exit 0
   end.
)

getval =: 3 : 0
   fd =. wd 'qd'
   >(((<y) E. 0{|:fd) i. 1) { (1{|:fd)
)

NB. Start GUI
meteo_run''

NB. ****************************************************************************
NB. EOF
NB. ****************************************************************************
