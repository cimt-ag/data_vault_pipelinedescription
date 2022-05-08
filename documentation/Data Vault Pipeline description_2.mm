<map version="1.0.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1635590898857" ID="ID_1388939787" MODIFIED="1639501519982" TEXT="Data Vault Pipeline Description">
<node CREATED="1635847711555" ID="ID_448091686" MODIFIED="1639501919943" POSITION="left" TEXT="Legende">
<node CREATED="1635847718490" ID="ID_1570997174" MODIFIED="1635847725640" TEXT="Pflichtfed"/>
<node COLOR="#006699" CREATED="1635847726412" ID="ID_955369522" MODIFIED="1635847752603" TEXT="Optionales Feld(default)"/>
<node COLOR="#338800" CREATED="1635847746227" ID="ID_1211268797" MODIFIED="1635847791171" TEXT="Mind Map strukturhilfe">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#999999" CREATED="1635857007002" ID="ID_327024112" MODIFIED="1635857019243" TEXT="m&#xf6;glicher Wert">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node CREATED="1635854647557" ID="ID_925206444" MODIFIED="1635854709183" TEXT="Unique key">
<icon BUILTIN="bookmark"/>
</node>
<node CREATED="1635854728131" ID="ID_1087812685" MODIFIED="1635856828075" TEXT="foreign key / must match to other elements">
<icon BUILTIN="forward"/>
</node>
<node CREATED="1647961027694" ID="ID_550319279" MODIFIED="1647961087212" TEXT="still in design discussion">
<icon BUILTIN="messagebox_warning"/>
</node>
<node CREATED="1651236336458" ID="ID_1473017318" MODIFIED="1651236581375" TEXT="Tool Support Level">
<node CREATED="1651236582316" ID="ID_1914033144" MODIFIED="1651236614049" TEXT="(no indication), absolute core"/>
<node CREATED="1651236605269" ID="ID_1639494952" MODIFIED="1651236642081" TEXT="core">
<icon BUILTIN="full-1"/>
</node>
<node CREATED="1651236650342" ID="ID_140539909" MODIFIED="1651236671205" TEXT="highly recommended">
<icon BUILTIN="full-2"/>
</node>
<node CREATED="1651236804925" ID="ID_442279732" MODIFIED="1651236853719" TEXT="recommended for full generic approach">
<icon BUILTIN="full-3"/>
</node>
<node CREATED="1651236876006" ID="ID_1779396070" MODIFIED="1651236948085" TEXT="best practice">
<icon BUILTIN="full-4"/>
</node>
<node CREATED="1651236672990" ID="ID_1914527896" MODIFIED="1651236936092" TEXT="proposal from already existing usecase">
<icon BUILTIN="full-5"/>
</node>
<node CREATED="1651237192808" ID="ID_1112406765" MODIFIED="1651237209988" TEXT="proposal from theoretical analysis">
<icon BUILTIN="full-9"/>
</node>
<node CREATED="1651936548407" ID="ID_1349259543" MODIFIED="1651936563207" TEXT="extention">
<icon BUILTIN="wizard"/>
</node>
</node>
</node>
<node COLOR="#338800" CREATED="1635608684004" ID="ID_248427842" MODIFIED="1649494427898" POSITION="left" TEXT="Pipeline_properties">
<node CREATED="1635608696419" ID="ID_1219639437" MODIFIED="1635846237551" TEXT="pipeline_name"/>
<node CREATED="1635608711956" ID="ID_359976325" MODIFIED="1649608430799" TEXT="DR">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1635863259518" ID="ID_108187273" MODIFIED="1635863273502" TEXT="documentation_url"/>
<node CREATED="1635592387045" ID="ID_801462239" MODIFIED="1639501703968" TEXT="Record_source_Name_expression">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      May contain some extarnal given parts
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1635854830666" ID="ID_1329612744" MODIFIED="1639501705048" POSITION="left" TEXT="data_extraction">
<node CREATED="1635854850522" ID="ID_102518382" MODIFIED="1635855505873" TEXT="fetch_module_name"/>
<node CREATED="1639501308838" ID="ID_255592885" MODIFIED="1639501319029" TEXT="increment_logic"/>
<node COLOR="#338800" CREATED="1635854900058" ID="ID_50855217" MODIFIED="1635856972915" TEXT="file">
<font NAME="SansSerif" SIZE="12"/>
<node CREATED="1635854943938" ID="ID_1643708687" MODIFIED="1635854951518" TEXT="search_expression"/>
<node CREATED="1635854952203" ID="ID_1478158046" MODIFIED="1635854959592" TEXT="file_archive_path"/>
<node CREATED="1635592576959" ID="ID_1383447320" MODIFIED="1639501119695" TEXT="Reject procedure">
<node COLOR="#999999" CREATED="1635592588790" ID="ID_1053241767" MODIFIED="1635856944547" TEXT="Separate rows">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635592595479" ID="ID_1070384374" MODIFIED="1635856945571" TEXT="Separate container">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1639497509835" ID="ID_68069511" MODIFIED="1639497846679" TEXT="abort process">
<font NAME="SansSerif" SIZE="10"/>
</node>
</node>
</node>
<node COLOR="#338800" CREATED="1635854975506" ID="ID_1588445891" MODIFIED="1635856981773" TEXT="database_resultset">
<font NAME="SansSerif" SIZE="12"/>
<node CREATED="1635855047842" ID="ID_1509162014" MODIFIED="1635855051479" TEXT="Query"/>
<node CREATED="1635855067155" ID="ID_738787553" MODIFIED="1635855082496" TEXT="connection_identifier"/>
<node CREATED="1635855110998" ID="ID_484447053" MODIFIED="1635855120594" TEXT="Increment_logic"/>
</node>
<node COLOR="#338800" CREATED="1635855134735" ID="ID_1502849933" MODIFIED="1635856977675" TEXT="kafka_stream">
<font NAME="SansSerif" SIZE="12"/>
<node CREATED="1635855152080" ID="ID_234912179" MODIFIED="1635855187261" TEXT="connection_identifier"/>
<node CREATED="1635855187882" ID="ID_1214001702" MODIFIED="1635855191797" TEXT="queue"/>
</node>
<node CREATED="1635855537381" ID="ID_1661485435" MODIFIED="1635855552711" TEXT="parse_module_name"/>
<node COLOR="#338800" CREATED="1635592068454" ID="ID_1928846846" MODIFIED="1635855613519" TEXT="json"/>
<node COLOR="#338800" CREATED="1635592157958" ID="ID_1272401764" MODIFIED="1635855652626" TEXT="delimited_text">
<node CREATED="1635854963611" ID="ID_1260961664" MODIFIED="1635854970887" TEXT="codepage"/>
<node CREATED="1635855621414" ID="ID_323776420" MODIFIED="1635855628147" TEXT="column_separator"/>
<node CREATED="1635855632831" ID="ID_363638556" MODIFIED="1635855634674" TEXT="..."/>
</node>
<node COLOR="#338800" CREATED="1635592071871" ID="ID_719537905" MODIFIED="1635855614630" TEXT="xml"/>
<node COLOR="#338800" CREATED="1635592074390" ID="ID_198671657" MODIFIED="1635855616039" TEXT="positional"/>
</node>
<node CREATED="1639501361774" ID="ID_352139105" MODIFIED="1639501473792" POSITION="left" TEXT="Toolset">
<node CREATED="1635590992718" ID="ID_791075071" MODIFIED="1639501948101" TEXT="Data Vault Pipeline Designer">
<node CREATED="1635592649038" ID="ID_355731149" MODIFIED="1635592663747" TEXT="Retrieval of source Metadata"/>
<node CREATED="1635592667277" ID="ID_1582632412" MODIFIED="1635592807579" TEXT="Presentation of available dv Model"/>
<node CREATED="1635592681735" ID="ID_1465520058" MODIFIED="1635592718923" TEXT="Efficient UI">
<node CREATED="1635592719800" ID="ID_1373646846" MODIFIED="1635592736210" TEXT="create dv tables from source meta date"/>
<node CREATED="1635592737142" ID="ID_1989371547" MODIFIED="1635592759594" TEXT="&quot;Tweak&quot; dv tables"/>
<node CREATED="1635592760287" ID="ID_1615400863" MODIFIED="1635592790850" TEXT="Map relations from source fields dv columns"/>
</node>
<node CREATED="1635592838454" ID="ID_95266126" MODIFIED="1635592846656" TEXT="Generate DVDP"/>
<node CREATED="1635592873832" ID="ID_384624918" MODIFIED="1635592903168" TEXT="Assist to keep consistencys">
<node CREATED="1635592904123" ID="ID_1291458851" MODIFIED="1635592909755" TEXT="one source, one sat"/>
<node CREATED="1635592923377" ID="ID_667280698" MODIFIED="1635592934658" TEXT="Validation rules"/>
<node CREATED="1635608775532" ID="ID_1460490111" MODIFIED="1635608798225" TEXT="consistency to hubs/links of full model"/>
</node>
</node>
<node CREATED="1635590979638" ID="ID_317439264" MODIFIED="1639501956183" TEXT="Data Vault Pipeline Description Compiler">
<node CREATED="1635592860476" ID="ID_962009790" MODIFIED="1635592982964" TEXT="Check DV model conistency">
<node CREATED="1635593122629" ID="ID_1463949912" MODIFIED="1635593132618" TEXT="Tables and columns unique"/>
<node CREATED="1635593133462" ID="ID_247818599" MODIFIED="1635593206318" TEXT="Flags are compatible to stereotype"/>
<node CREATED="1635593669990" ID="ID_1610311073" MODIFIED="1635593685962" TEXT="Mandantory_properties_are_set"/>
<node CREATED="1635592983682" ID="ID_909728920" MODIFIED="1635593174266" TEXT="Parent(s) exist"/>
<node CREATED="1635593401701" ID="ID_297862935" MODIFIED="1635593409378" TEXT="warn for missing esats"/>
</node>
<node CREATED="1635957325635" ID="ID_644960381" MODIFIED="1635957366768" TEXT="Check DV model integration to existing model">
<node CREATED="1635957367571" ID="ID_736391583" MODIFIED="1635957494040" TEXT="hub  and link columns match"/>
<node CREATED="1635957401483" ID="ID_142232356" MODIFIED="1635957431551" TEXT="satellites are unique"/>
<node CREATED="1635957516555" ID="ID_1975265493" MODIFIED="1635957526864" TEXT="warn about identical links"/>
</node>
<node CREATED="1635593500974" ID="ID_670499104" MODIFIED="1635593507785" TEXT="Check mapping consistency">
<node CREATED="1635957166244" ID="ID_411812892" MODIFIED="1635957303782" TEXT="mapping is unambiguous"/>
<node CREATED="1635593561253" ID="ID_256576400" MODIFIED="1635593579330" TEXT="columns for partitioned deletion are in model"/>
</node>
</node>
<node CREATED="1635590963294" ID="ID_791227296" MODIFIED="1639501958511" TEXT="Data Vaul Pipeline Execution">
<node CREATED="1635594082335" ID="ID_346521424" MODIFIED="1635594444048" TEXT="Determine needed DV Objects for every Target set"/>
<node CREATED="1635593629957" ID="ID_1534741910" MODIFIED="1635593763395" TEXT="prepare_data_model">
<node CREATED="1635593991909" ID="ID_1948707729" MODIFIED="1635594009560" TEXT="render DDL for Encryption Tables"/>
<node COLOR="#000000" CREATED="1635593764176" ID="ID_1891153867" MODIFIED="1635593942265" TEXT="render DDL for  RAW Vault"/>
<node CREATED="1635593983606" ID="ID_1865174820" MODIFIED="1635956978466" TEXT="render Stage DDL for every necessary field set"/>
<node CREATED="1635594027910" ID="ID_1321113822" MODIFIED="1635594033666" TEXT="Deploy missing tables"/>
</node>
<node CREATED="1635594619037" ID="ID_1536879600" MODIFIED="1635956997663" TEXT="Stage Data">
<node CREATED="1635957020277" ID="ID_1007564747" MODIFIED="1635957074405" TEXT="Check compliance to specification">
<node CREATED="1635957092363" ID="ID_685123395" MODIFIED="1635957100119" TEXT="Expected fields"/>
<node CREATED="1635957100571" ID="ID_1096849360" MODIFIED="1635957109439" TEXT="Key uniqueness"/>
</node>
<node CREATED="1635957000670" ID="ID_540073597" MODIFIED="1635957076598" TEXT="technical cleansing data"/>
<node CREATED="1635594837078" ID="ID_1589486096" MODIFIED="1635594882834" TEXT="Calculate RH / GH"/>
</node>
<node CREATED="1635594659246" ID="ID_1705320535" MODIFIED="1635594669881" TEXT="Load Data to Vault"/>
</node>
</node>
<node CREATED="1635592091143" ID="ID_1350680042" MODIFIED="1635846314287" POSITION="right" TEXT="fields[]">
<node CREATED="1635592197071" ID="ID_1098838675" MODIFIED="1645802073530" TEXT="field_name">
<icon BUILTIN="bookmark"/>
</node>
<node CREATED="1635592280909" ID="ID_392281183" MODIFIED="1649841830359" TEXT="field_type">
<node COLOR="#999999" CREATED="1635592306942" ID="ID_1013523092" MODIFIED="1635856148510" TEXT="varchar(x)">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635592310270" ID="ID_1416812576" MODIFIED="1635855946129" TEXT="json">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635592314581" ID="ID_1055858993" MODIFIED="1635855947505" TEXT="timestamp">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635592318934" ID="ID_1955621803" MODIFIED="1635855949761" TEXT="....">
<font NAME="SansSerif" SIZE="10"/>
</node>
</node>
<node COLOR="#006699" CREATED="1635592204895" ID="ID_1124963661" MODIFIED="1651236779602" TEXT="Parsing_expression">
<icon BUILTIN="full-2"/>
</node>
<node COLOR="#006699" CREATED="1635855970690" ID="ID_1297551217" MODIFIED="1651236786462" TEXT="uniqueness_groups[]">
<icon BUILTIN="full-5"/>
</node>
<node COLOR="#006699" CREATED="1635593798982" ID="ID_1726734370" MODIFIED="1651236966311" TEXT="needs_encryption=false">
<icon BUILTIN="full-4"/>
</node>
<node CREATED="1635592213279" ID="ID_777241347" MODIFIED="1635857506363" TEXT="targets[]">
<node CREATED="1635592233422" ID="ID_600624307" MODIFIED="1635856880294" TEXT="Table_Name">
<icon BUILTIN="forward"/>
</node>
<node COLOR="#006699" CREATED="1635592243679" ID="ID_1114463808" MODIFIED="1639501438218" TEXT="target_column_name=&lt;field_name&gt;">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      canbe META_IS_DELETED to provide explicit deletion data
    </p>
  </body>
</html></richcontent>
</node>
<node COLOR="#006699" CREATED="1635591229782" ID="ID_529770496" MODIFIED="1635865319050" TEXT="target_column_type=&lt;techical_type&gt;"/>
<node COLOR="#006699" CREATED="1647945524605" ID="ID_421896321" MODIFIED="1651236992709" TEXT="recursion_name">
<arrowlink DESTINATION="ID_1084442198" ENDARROW="Default" ENDINCLINATION="165;0;" ID="Arrow_ID_890285373" STARTARROW="None" STARTINCLINATION="625;0;"/>
<icon BUILTIN="forward"/>
<icon BUILTIN="full-1"/>
</node>
<node COLOR="#006699" CREATED="1635594257893" ID="ID_1820031178" MODIFIED="1651936658251" TEXT="field_groups[]">
<linktarget COLOR="#b0b0b0" DESTINATION="ID_1820031178" ENDARROW="Default" ENDINCLINATION="645;0;" ID="Arrow_ID_744515587" SOURCE="ID_1447805734" STARTARROW="None" STARTINCLINATION="642;11;"/>
<linktarget COLOR="#b0b0b0" DESTINATION="ID_1820031178" ENDARROW="Default" ENDINCLINATION="827;0;" ID="Arrow_ID_1257892091" SOURCE="ID_448134744" STARTARROW="None" STARTINCLINATION="827;0;"/>
<icon BUILTIN="forward"/>
<icon BUILTIN="full-1"/>
<node COLOR="#999999" CREATED="1635856220618" ID="ID_1323119577" MODIFIED="1635861526680" TEXT="&quot;some free chosen name&quot;">
<font NAME="SansSerif" SIZE="10"/>
</node>
</node>
<node COLOR="#006699" CREATED="1643102305443" ID="ID_1744035501" MODIFIED="1643102329984" TEXT="exclude_from_key_hash=false">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1635857407132" ID="ID_1245933827" MODIFIED="1635857419236" TEXT="exclude_from_diff_hash=false"/>
<node COLOR="#006699" CREATED="1635591291374" ID="ID_288289947" MODIFIED="1647770681998" TEXT="prio_in_diff_hash=0"/>
<node COLOR="#006699" CREATED="1647770327636" ID="ID_904714341" MODIFIED="1647770376714" TEXT="prio_in_key_hash=0"/>
<node COLOR="#006699" CREATED="1635591336350" ID="ID_1009970361" MODIFIED="1651237011981" TEXT="hash_cleasing_rules[]">
<icon BUILTIN="full-2"/>
<node COLOR="#006699" CREATED="1635591360718" ID="ID_1834184487" MODIFIED="1635856651103" TEXT="trim=false"/>
<node COLOR="#006699" CREATED="1635591364775" ID="ID_1609500649" MODIFIED="1635856644423" TEXT="lower case / upper case=false"/>
<node COLOR="#006699" CREATED="1635591375174" ID="ID_1974579049" MODIFIED="1635856660960" TEXT="format=no change"/>
<node CREATED="1635591382839" ID="ID_140889450" MODIFIED="1635591384178" TEXT="..."/>
</node>
<node COLOR="#006699" CREATED="1635591314431" ID="ID_1304316423" MODIFIED="1635857527648" TEXT="column_content_comment=&lt;field_comment&gt;"/>
</node>
<node COLOR="#006699" CREATED="1635857507548" ID="ID_1870604769" MODIFIED="1635857536489" TEXT="field_comment=&lt;none&gt;"/>
</node>
<node CREATED="1635591044231" ID="ID_141613353" MODIFIED="1639501573171" POSITION="right" TEXT="Data Vault Model[]">
<node CREATED="1635857102443" ID="ID_1509841484" MODIFIED="1635857224848" TEXT="schema_name">
<icon BUILTIN="bookmark"/>
</node>
<node CREATED="1635591057775" ID="ID_315697449" MODIFIED="1635857185299" TEXT="Tables[]">
<node CREATED="1635591112182" ID="ID_884068126" MODIFIED="1635857229575" TEXT="Table_Name">
<icon BUILTIN="bookmark"/>
</node>
<node CREATED="1635591118910" ID="ID_866423636" MODIFIED="1635857207951" TEXT="Stereotype">
<node COLOR="#999999" CREATED="1635861234558" ID="ID_772965079" MODIFIED="1635861256903" TEXT="hub">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635614778995" ID="ID_1511736817" MODIFIED="1643102351757" TEXT="lnk">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635591135502" ID="ID_1715958406" MODIFIED="1635861258022" TEXT="sat">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1635591138550" ID="ID_1887632413" MODIFIED="1635861258942" TEXT="...">
<font NAME="SansSerif" SIZE="10"/>
</node>
</node>
<node COLOR="#006699" CREATED="1635591143990" ID="ID_1219684394" MODIFIED="1635857795085" TEXT="Table_content_comment"/>
<node COLOR="#006699" CREATED="1639502995504" ID="ID_130913505" MODIFIED="1652020728429" TEXT="data_vault_model_profile_name">
<icon BUILTIN="forward"/>
<icon BUILTIN="full-2"/>
</node>
<node COLOR="#006699" CREATED="1651936777832" ID="ID_963713144" MODIFIED="1651937198776" TEXT="xenc_encryption_key_table_name">
<icon BUILTIN="wizard"/>
</node>
<node COLOR="#338800" CREATED="1635591125382" ID="ID_489854946" MODIFIED="1635857737645" TEXT="Hub">
<node CREATED="1635591158758" ID="ID_735553646" MODIFIED="1635857274088" TEXT="hub_key_column_name"/>
</node>
<node COLOR="#338800" CREATED="1635591130581" ID="ID_1872118186" MODIFIED="1645531731645" TEXT="(d)lnk">
<node CREATED="1635591158758" ID="ID_1586095817" MODIFIED="1635857703024" TEXT="link_key_column_name"/>
<node CREATED="1635591429430" ID="ID_1970489108" MODIFIED="1635867793143" TEXT="link_parent_tables[]">
<icon BUILTIN="forward"/>
</node>
<node COLOR="#006699" CREATED="1639566757442" ID="ID_1194628431" MODIFIED="1647945379372" TEXT="recursive_parents[]">
<node CREATED="1639566772480" ID="ID_1155157973" MODIFIED="1639566778875" TEXT="table_name"/>
<node CREATED="1639566779721" ID="ID_1084442198" MODIFIED="1651237059635" TEXT="recursion_name">
<linktarget COLOR="#b0b0b0" DESTINATION="ID_1084442198" ENDARROW="Default" ENDINCLINATION="165;0;" ID="Arrow_ID_890285373" SOURCE="ID_421896321" STARTARROW="None" STARTINCLINATION="625;0;"/>
<icon BUILTIN="full-1"/>
</node>
<node CREATED="1645792672091" ID="ID_1913384705" MODIFIED="1647946310258" TEXT="field_group">
<icon BUILTIN="messagebox_warning"/>
</node>
</node>
<node COLOR="#006699" CREATED="1635593437918" ID="ID_1578849827" MODIFIED="1651237073648" TEXT="is_link_without_sat=false">
<icon BUILTIN="full-1"/>
</node>
<node COLOR="#006699" CREATED="1635863191686" ID="ID_1447805734" MODIFIED="1651237066574" TEXT="tracked_field_groups[](empty=all)">
<arrowlink COLOR="#b0b0b0" DESTINATION="ID_1820031178" ENDARROW="Default" ENDINCLINATION="645;0;" ID="Arrow_ID_744515587" STARTARROW="None" STARTINCLINATION="642;11;"/>
<icon BUILTIN="forward"/>
<icon BUILTIN="full-1"/>
</node>
<node COLOR="#999999" CREATED="1650988676459" ID="ID_271365744" MODIFIED="1651237084476" TEXT="link_key_assemble_rule">
<font NAME="SansSerif" SIZE="10"/>
<icon BUILTIN="full-2"/>
</node>
<node COLOR="#999999" CREATED="1650987575290" ID="ID_1633454685" MODIFIED="1651237091336" TEXT="link_key_explicit_content_order[]">
<font NAME="SansSerif" SIZE="10"/>
<icon BUILTIN="full-2"/>
</node>
</node>
<node COLOR="#338800" CREATED="1635591133445" ID="ID_1023039978" MODIFIED="1635863310915" TEXT="(m)Sat">
<node CREATED="1635591403053" ID="ID_310503244" MODIFIED="1635864050438" TEXT="satellite_parent_table">
<icon BUILTIN="forward"/>
</node>
<node COLOR="#006699" CREATED="1645799057096" ID="ID_802621925" MODIFIED="1645799078679" TEXT="is_multiactive=false"/>
<node COLOR="#006699" CREATED="1635591191056" ID="ID_775893793" MODIFIED="1635859593904" TEXT="Diff_hash_column_name"/>
<node COLOR="#006699" CREATED="1649936235138" ID="ID_1385377190" MODIFIED="1649936258669" TEXT="is_historized=true"/>
<node COLOR="#006699" CREATED="1635591503286" ID="ID_1917303428" MODIFIED="1651237120874" TEXT="max_history_depth">
<icon BUILTIN="full-3"/>
<node CREATED="1635591519839" ID="ID_961347965" MODIFIED="1645800155166" TEXT="max_versions"/>
<node CREATED="1635591532590" ID="ID_1126178104" MODIFIED="1635591542203" TEXT="max_valid_before_age"/>
</node>
<node COLOR="#006699" CREATED="1645531779969" ID="ID_858311196" MODIFIED="1649329878296" TEXT="driving_keys[] (only when link is parent)">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1651936618064" ID="ID_576239854" MODIFIED="1651937178569" TEXT="xenc_encyption_key_index_column_name">
<icon BUILTIN="wizard"/>
</node>
<node COLOR="#cccccc" CREATED="1635863373886" ID="ID_1593979965" MODIFIED="1635863912121" TEXT="content enddate feature properties">
<font NAME="SansSerif" SIZE="12"/>
</node>
</node>
<node COLOR="#338800" CREATED="1635862943227" ID="ID_198135584" MODIFIED="1635862987371" TEXT="Esat">
<node CREATED="1635862947307" ID="ID_1156947379" MODIFIED="1635864044824" TEXT="satellite_parent_table">
<icon BUILTIN="forward"/>
</node>
<node COLOR="#006699" CREATED="1635861485894" ID="ID_448134744" MODIFIED="1651936658251" TEXT="tracked_field_groups[] (empty=all)">
<arrowlink COLOR="#b0b0b0" DESTINATION="ID_1820031178" ENDARROW="Default" ENDINCLINATION="827;0;" ID="Arrow_ID_1257892091" STARTARROW="None" STARTINCLINATION="827;0;"/>
<icon BUILTIN="forward"/>
<icon BUILTIN="full-1"/>
</node>
<node COLOR="#006699" CREATED="1635862962203" ID="ID_1777241741" MODIFIED="1651237143738" TEXT="max_history_depth">
<icon BUILTIN="full-3"/>
</node>
<node COLOR="#006699" CREATED="1635869536568" ID="ID_716765691" MODIFIED="1649329973467" TEXT="driving_keys[]"/>
</node>
<node COLOR="#338800" CREATED="1645531607434" ID="ID_1093678454" MODIFIED="1651936665218" TEXT="ref">
<node CREATED="1645531620776" ID="ID_800855086" MODIFIED="1645531643975" TEXT="diff_hash_column_name"/>
<node CREATED="1645531645080" ID="ID_14713348" MODIFIED="1645531694905" TEXT="is_historized=yes"/>
</node>
<node COLOR="#338800" CREATED="1651936668714" ID="ID_1700145203" MODIFIED="1651937156556" TEXT="xenc_hub-ek">
<icon BUILTIN="wizard"/>
<node COLOR="#006699" CREATED="1651936757449" ID="ID_619861089" MODIFIED="1651937106835" TEXT="xenc_encryption_key_column_name">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1651936840434" ID="ID_341302855" MODIFIED="1651937113387" TEXT="xenc_content_hash_column_name"/>
<node COLOR="#006699" CREATED="1651936857794" ID="ID_1863737459" MODIFIED="1651937116451" TEXT="xenc_content_salted_hash_column_name">
<font NAME="SansSerif" SIZE="12"/>
</node>
</node>
<node COLOR="#338800" CREATED="1651936710154" ID="ID_861265585" MODIFIED="1651937164278" TEXT="xenc_lnk-ek">
<icon BUILTIN="wizard"/>
<node COLOR="#006699" CREATED="1651936757449" ID="ID_434350178" MODIFIED="1651937119375" TEXT="xenc_encryption_key_column_name">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1651936840434" ID="ID_1195308843" MODIFIED="1651937121301" TEXT="xenc_content_hash_column_name"/>
<node COLOR="#006699" CREATED="1651936857794" ID="ID_1724119951" MODIFIED="1651937124678" TEXT="xenc_content_salted_hash_column_name">
<font NAME="SansSerif" SIZE="12"/>
</node>
</node>
<node COLOR="#338800" CREATED="1651936714385" ID="ID_988554298" MODIFIED="1651937169823" TEXT="xenc_sat-ek">
<icon BUILTIN="wizard"/>
<node COLOR="#006699" CREATED="1651936757449" ID="ID_1407751114" MODIFIED="1651937126783" TEXT="xenc_encryption_key_column_name">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1651936618064" ID="ID_47752339" MODIFIED="1651937129139" TEXT="xenc_encyption_key_index_column_name"/>
<node COLOR="#006699" CREATED="1651937303418" ID="ID_1703873018" MODIFIED="1651937310057" TEXT="diff_hash_column_name"/>
</node>
<node COLOR="#006699" CREATED="1635857115836" ID="ID_212032485" MODIFIED="1651237151676" TEXT="storage_component">
<icon BUILTIN="full-3"/>
</node>
</node>
</node>
<node COLOR="#006699" CREATED="1651042660323" ID="ID_883713473" MODIFIED="1651662057515" POSITION="right" TEXT="deletion_detection">
<icon BUILTIN="full-2"/>
<node CREATED="1651042676370" ID="ID_1201234597" MODIFIED="1651223693176" TEXT="phase">
<node COLOR="#999999" CREATED="1651223694318" ID="ID_52026152" MODIFIED="1651223716036" TEXT="fetch">
<font NAME="SansSerif" SIZE="10"/>
</node>
<node COLOR="#999999" CREATED="1651223703540" ID="ID_1423093139" MODIFIED="1651223714518" TEXT="load">
<font NAME="SansSerif" SIZE="10"/>
</node>
</node>
<node COLOR="#338800" CREATED="1651042687963" ID="ID_1674392943" MODIFIED="1651223738188" TEXT="load">
<node CREATED="1651223748485" ID="ID_1643226942" MODIFIED="1651223763462" TEXT="deletion_rules[]">
<node COLOR="#006699" CREATED="1651224016036" ID="ID_38215216" MODIFIED="1651245433229" TEXT="rule_comment"/>
<node CREATED="1651223765876" ID="ID_841652477" MODIFIED="1651223786521" TEXT="tables[]"/>
<node COLOR="#006699" CREATED="1651223804324" ID="ID_1853074592" MODIFIED="1651223850517" TEXT="partitioning_fields[]">
<font NAME="SansSerif" SIZE="12"/>
</node>
<node COLOR="#006699" CREATED="1651236151272" ID="ID_1210727292" MODIFIED="1651237217258" TEXT="join_path[]">
<icon BUILTIN="full-9"/>
<node COLOR="#999999" CREATED="1651236223288" ID="ID_1247811601" MODIFIED="1651236303646" TEXT="for links with sat, use sat">
<font NAME="SansSerif" SIZE="10"/>
</node>
</node>
</node>
</node>
</node>
<node CREATED="1639502603647" ID="ID_203916305" MODIFIED="1652020142776" POSITION="right" TEXT="Data Vault Model Profiles[]">
<node CREATED="1639502638351" ID="ID_403748373" MODIFIED="1639502656986" TEXT="data_vault_profile_name"/>
<node CREATED="1639502657751" ID="ID_882854494" MODIFIED="1639502702362" TEXT="hash_algorhythm"/>
<node CREATED="1639502678607" ID="ID_887825474" MODIFIED="1639502688427" TEXT="hash_column_type"/>
<node CREATED="1639502710663" ID="ID_1151194852" MODIFIED="1639502723787" TEXT="hash_field_separator"/>
<node CREATED="1639502724480" ID="ID_544505211" MODIFIED="1639502923898" TEXT="number_format_for_hash"/>
<node CREATED="1639502749367" ID="ID_1601158480" MODIFIED="1639502763570" TEXT="timestamp_format_for_hash"/>
<node CREATED="1639502770694" ID="ID_834226042" MODIFIED="1639502830768" TEXT="representation_of_field_content_NULL"/>
<node CREATED="1639502802942" ID="ID_795608329" MODIFIED="1639502847859" TEXT="hash_value_for_delivered_null"/>
<node CREATED="1639502834079" ID="ID_1943525651" MODIFIED="1639502852563" TEXT="hash_value_for_missing"/>
<node CREATED="1639502865279" ID="ID_856132515" MODIFIED="1639502882491" TEXT="column_name_for_inserted_at"/>
<node CREATED="1639502883063" ID="ID_1408293140" MODIFIED="1639502897765" TEXT="column_name_for_..."/>
<node CREATED="1639502946879" ID="ID_495594513" MODIFIED="1639502966050" TEXT="...more generator basic properties..."/>
</node>
</node>
</map>
