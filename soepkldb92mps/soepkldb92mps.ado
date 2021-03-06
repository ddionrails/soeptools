/*
SOEP - Klassifikation der Berufe 92                     
Datendefinition fuer SOEP: MPS_KldB92                  
Routine fuer Zuweisung von MPS_KldB Werten zur Berufsvariablen (STAB__)                           

!!! Bei Nutzung dieser Routine bitte wie folgt zitieren:   
Frietsch, Rainer/Wirth, Heike (2001):  Die Uebertragung der 
Magnitude-Prestigeskala von Wegener auf die Klassifikation der Berufe              
In: ZUMA Nachrichten 48 (Jg.25): 139-165     

siehe auch:

http://www.gesis.org/missy/materials/MZ/tools/mps
http://www.gesis.org/das-institut/kompetenzzentren/fdz-german-microdata-lab/forschung/konstruktion-der-magnitude-prestigeskala-mps/
http://www.gesis.org/missy/files/documents/MZ/mps_kldB_92.pdf

------------------------------------------------------------------*/   

program soepkldb92mps
	syntax varname, mps(string)
		
	* MPS ist f�r kldb92-3steller von 0110 bis 9379 definiert
	generate `mps' = int((`varlist'/10)) if inrange(`varlist',110,9379)
    /*die Funktion int entspricht dem befehl trunc in spss*/
	recode `mps' ///
	(11=35.1)	(12=42.7)	(13=30.1)	(14=30.0)	(23=41.1)	(24=33.4)  ///
	(31=79.7)	(32=84.9)	(51=32.4)	(52=64.9)	(53=52.9)	(61=64.0)  ///  
	(62=31.8)	(70=35.3)	(71=35.3)	(72=46.1)	(80=35.9)	(101=47.2)  ///  
	(112=31.2)	(121=31.7)	(131=35.6)	(135=33.1)	(141=36.8)	(142=49.1)  ///  
	(145=34.6)	(150=32.8)	(152=32.8)	(153=32.8)	(161=32.9)	(162=31.5)  ///  
	(164=32.1)	(171=51.2)	(172=50.3)	(173=50.3)	(174=48.9)	(175=35.1)  ///
	(176=49.9)	(178=39.5)	(179=39.5)	(181=31.2)	(185=35.3)	(191=33.4)  ///  
	(194=32.1)	(201=35.0)	(211=31.9)	(212=32.1)	(213=32.9)	(220=32.0)  ///  
	(221=35.9)	(222=33.5)	(224=36.1)	(225=32.9)	(229=32.0)	(231=32.4)  ///  
	(233=39.2)	(234=35.6)	(235=36.2)	(241=35.4)	(245=35.2)	(250=38.8)  ///  
	(252=36.1)	(254=38.8)	(255=37.5)	(256=38.8)	(259=38.8)	(261=39.3)  ///  
	(264=44.2)	(265=39.3)	(266=43.6)	(267=44.2)	(268=44.2)	(269=44.2)  ///  
	(270=43.6)	(273=40.8)	(274=37.4)	(276=43.6)	(278=43.6)	(281=46.0)  ///  
	(282=42.8)	(283=49.1)	(287=39.3)	(290=41.6)	(292=41.6)	(293=41.6)  ///  
	(294=41.6)	(295=47.4)	(300=47.4)	(302=54.0)	(303=64.9)	(304=72.2)  ///  
	(305=45.2)	(307=47.4)	(308=53.6)	(309=48.4)	(310=47.7)	(311=47.7)  ///  
	(312=48.6)	(313=44.3)	(315=50.2)	(316=50.2)	(317 =50.2)	(318=47.7)  ///  
	(321=35.6)	(322=38.5)	(323=31.7)	(331=31.5)	(332=32.6)	(341=35.2)  ///  
	(344=35.6)	(349=33.7)	(351=48.0)	(352=33.5)	(353=33.0)	(354=34.2)  ///  
	(358=34.2)	(359=35.4)	(361=35.0)	(371=36.1)	(372=50.2)	(373=30.3)  ///  
	(374=40.7)	(376=32.2)	(378=53.2)	(391=51.6)	(392=52.5)	(393=33.0)  ///  
	(401=52.3)	(411=45.1)	(421=42.7)	(423=35.8)	(424=38.5)	(431=41.1)  ///  
	(435=41.1)	(440=39.2)	(441=39.2)	(442=39.2)	(443=37.2)	(460=44.2)  ///  
	(461=32.1)	(463=32.7)	(465=33.1)	(466=44.2)	(471=30.3)	(472=30.2)  ///  
	(480=41.7)	(481=40.8)	(482=42.8)	(483=47.8)	(484=49.1)	(485=40.9)  ///  
	(486=39.2)	(487=41.7)	(488=38.7)	(491=49.6)	(492=35.4)	(501=42.5)  ///  
	(502=41.4)	(505=42.5)	(506=37.3)	(510=44.2)	(511=44.2)	(512=36.4)  ///  
	(514=46.1)	(521=43.1)	(522=32.1)	(523=43.1)	(531=31.0)	(540=34.2)  ///  
	(541=42.5)	(544=32.2)	(545=32.5)	(546=33.1)	(549=34.2)	(550=36.1)  ///  
	(600=88.3)	(601=103.5)	(602=89.6)	(603=111.7)	(604=85.7)	(605=91.0)  ///  
	(606=104.6)	(607=88.3)	(608=88.3)	(609=111.7)	(611=123.9)	(612=125.2) ///
	(620=67.5)	(621=69.7)	(622=61.8)	(623=71.2)	(624=53.4)	(625=91.0)  ///  
	(626=72.1)	(627=67.7)	(628=67.5)	(629=67.5)	(631=60.7)	(632=50.2)  ///  
	(633=53.1)	(634=53.1)	(641=52.7)	(642=52.7)	(651=63.9)	(652=63.9)  ///  
	(660=51.1)	(661=51.1)	(662=51.1)	(663=51.1)	(670=78.0)	(671=78.0)  ///  
	(672=78.0)	(673=78.0)	(674=80.7)	(675=69.7)	(676=78.0)	(677=78.0)  ///  
	(678=78.0)	(683=80.7)	(685=51.6)	(686=46.1)	(687=68.8)	(689=68.8)  ///  
	(691=74.1)	(692=68.9)	(695=71.0)	(701=61.0)	(702=69.2)	(703=71.9)  ///  
	(704=80.6)	(705=54.2)	(706=47.8)	(711=50.1)	(712=49.5)	(713=51.8)  ///  
	(714=35.1)	(715=35.1)	(716=35.5)	(721=80.3)	(723=46.1)	(724=49.8)  ///  
	(726=79.8)	(731=52.5)	(732=48.3)	(735=50.3)	(741=37.1)	(742=31.1)  ///  
	(743=36.2)	(744=31.5)	(750=101.3)	(751=101.3)	(753=106)	(754=106)   /// 
	(755=90.1)	(756=90.1)	(757=90.1)	(761=153.5)	(763=80.0)	(764=84.7)  ///  
	(765=84.7)	(771=68.9)	(772=64.7)	(773=53.3)	(774=79.6)	(775=79.6)  ///  
	(776=79.6)	(777=79.6)	(778=79.6)	(779=79.6)	(780=60.4)	(782=53.2)  ///  
	(783=53.3)	(784=42.9)	(785=60.4)	(786=60.4)	(787=60.4)	(788=60.4)  ///  
	(789=53.2)	(791=46.2)	(792=36.5)	(793=39.1)	(794=36.1)	(795=67.6)  ///  
	(796=39.1)	(801=63.0)	(802=52.9)	(803=53.1)	(804=61.1)	(805=51.7)  ///  
	(811=138.2)	(812=84.7) (813=145.7) (814=53.5)	(821=85.4)	(822=80.9)  ///  
	(823=80.3)	(831=78.1)	(832=80.4)	(833=69.1)	(834=69.1)	(835=54.1)  ///  
	(836=53.6)	(837=64.1)	(838=61.8)	(839=51.5)	(841=191.3)	(842=216)   /// 
	(843=138.9) (844=207.2) (851=80.8)	(852=61.2)	(853=51.5)	(854=43.1)  ///  
	(855=68.9)	(856=52.9)	(857=53.2)	(858=68.9)	(859=61.2)	(861=62.3)  ///  
	(862=62.3)	(863=62.3)	(864=62.3)	(865=62.3)	(866=62.3)	(867=62.3)  ///  
	(868=80.3)	(869=62.3)	(870=120.0) (871=152.5) (872=132.1)	(873=120.0) ///
	(874=104.6) (875=80.9)	(876=67.6)	(878=71.4)	(879=71.4)	(880=122.2) ///
	(881=135.7) (882=122.2) (883=139.8) (884=135.7)	(885=122.2)	(886=135.7) ///
	(887=135.7) (891=122.0) (894=54.7)	(901=60.6)	(902=44.4)	(911=53.9)  ///  
	(912=38.8)	(914=53.9)	(915=38.5)	(921=64.4)	(923=37.4)	(931=45.4)  ///  
	(934=32.3)	(935=32.6)	(936=32.5)	(937=32.3)
	lab var `mps' "MPS f�r `varlist'"
end
