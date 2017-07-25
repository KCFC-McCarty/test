
      $set sourceformat"free"
      $set fileshare
      $set ooctrl(+P)
*-----*-----------------------------------------------------------*
*     * Fee entry program                                         *
*-----*-----------------------------------------------------------*
*     * fee.cbl              ??/??/??    hrk                      *
*-----*-----------------------------------------------------------*
*     * This program accepts fees for recordings and              *
*     *      assigns book/page and file numbers as well           *
*     *      as providing a basis for the index entry             *
*-----*-----------------------------------------------------------*
*     * Not finished - adding receipts for multi-payoffs          *          
*-----*-----------------------------------------------------------*
                                                                                  
       special-names. crt status crt-status.
            
       class-control.  MSExcel is class "$OLE$Excel.Application".
       
           select fee-file   assign "\\kcffil01\clk\dat\feefile.dat"
                             organization indexed
                             access mode  dynamic
                             record key   fee-key
                             file status  file-stts.

           select ixcd-file  assign "\\kcffil01\clk\dat\ixcdfile.dat"
                             organization indexed
                             access mode  dynamic
                             record key   ic-key
                             file status  file-stts.

           select multi-tmp  assign "c:\clk\dat\mtmp.dat"            
                             organization indexed
                             access mode  dynamic
                             record key   mt-key
                             file status  file-stts.

           select fee-rcpt   assign "\\kcffil01\clk\dat\feercpt.dat"
                             organization indexed
                             access mode  dynamic
                             record key   rc-key
                             file status  file-stts.

           select optional
                  fees-jrnl  assign "\\kcffil01\clk\dat\feesjrnl.dat"
                             organization indexed
                             access mode  dynamic
                             record key   fees-jrnl-key
                             file status  file-stts.

           select indx-code  assign "\\kcffil01\clk\dat\indxcode.dat"
                             organization indexed
                             access mode  random
                             record key   indx-code-key
                             file status  file-stts.

           select notr-file  assign "\\kcffil01\clk\dat\notary.dat"
                             organization indexed
                             access mode  random
                             record key   notr-key
                             file status  file-stts.

           select deed-list  assign "\\kcffil01\clk\dat\deedlist.dat"
                             organization indexed
                             access mode  random
                             record key   deed-list-key
                             file status  file-stts.

           select dcmt-xref  assign "\\kcffil01\clk\dat\dcmtxref.dat"
                             organization indexed
                             access mode  random
                             record key   dcmt-xref-key
                             file status  file-stts.

           select fil-xrf    assign "\\kcffil01\clk\dat\filexrf.dat"
                  	     organization indexed
                             access mode  dynamic
                             record key   flx-key
                             file status  file-stts.
                             
           select print-file assign prnt-path.
           
           select itca-file  assign "com1".
/
       copy "FEE.LIB".
/
       copy "IXCD.LIB".
/                                                      
       copy "MTMP.LIB".
/
       copy "FEERCPT.LIB".
/                                                            
       copy "indxcode.cpb".                          
/
       copy "feesjrnl.cpb".
/
       copy "k:\clkx\src\deedlist.lib".
/
       copy "k:\clkx\src\dcmtxref.lib".
/       
       copy "k:\clkx\src\filxrf.lib".      
/
       fd  notr-file.

       01  notr-rcrd.
           02 notr-key.
              03 notr-dcmt      pic  9(14).
           02 notr-lctn         pic  x(01).
           02 notr-book         pic  9(04).
           02 notr-page         pic  9(04).
           02 notr-sufx         pic  x(01).

       fd  print-file.

       01  print-record         pic  x(80).
       
       fd  itca-file.
       
       01  itca-rcrd		pic x(40).
/
       working-storage section.

       01  cmos-date            pic  9(06).
       01  cmos-time            pic  9(08).

       01  file-stts.
           02 file-sts1         pic  9(01).
           02 file-sts2         pic  9(02) comp-x.

       01  lock-stts.
           02                   pic  9(01) value 09.
           02                   pic  9(02) comp-x value 68.

       01  file-nmbr            pic  9(02).
       01  nul-entry            pic  x(01).
       01  was-bsy              pic  x(01).
       01  prv-sc               pic  9(02).
       01  sys-mrd              pic  x(01).
       01  run-mode             pic  x(01).
       01  rec-cnt              pic  9(04).        
       01  fld-no               pic  9(02).
       01  kb-clk-id            pic  x(05).          
       01  kb-clctn-ch          pic  x(01).
       01  kb-sngl-mult         pic  x(01).
       01  kb-payoff            pic  x(01).
       01  kb-exempt            pic  x(03).    
       01  kb-validate          pic  x(01).
       01  kb-receipt           pic  x(01).
       01  kybd-lasr-rcpt       pic  x(01).
       01  kb-vl-chks           pic  x(01).
       01  valid-ch             pic  x(01).
       01  valid-clk-id         pic  x(01).
       01  blnk-line            pic  x(01) value space.
       01  kybd-okay            pic  x(01) value space.
       01  find-flag            pic  x(01).
       01  stg-cnt              pic  9(02).
       01  prv-byt              pic  x(01).
       01  end-scn              pic  x(01).        
       01  ws-this              pic  x(20).                 
       01  ws-nam-dsc           pic  x(05).
       01  byte-pntr		pic  9(02).
       01  strg-lent		pic  9(02).
       01  prog-lctn            pic  x(01) value space. 
       01  prnt-path		pic  x(60).  
       01  null-ntry            pic  x(01).         *> nul entry
       01  save-amnt-due        pic s9(06)v99.    
       01 save-nam2.
          02 save-nam2-last     pic  x(25).
          02 save-nam2-frst     pic  x(25).
          02 save-nam2-midl     pic  x(25).     
       
       01  kb-ok                pic  x(02).
       01  kb-no                redefines
           kb-ok                pic  9(02).         

       01  edt-date.                                                    
           02 edt-mt            pic  9(02).
           02                   pic  x(01)  value "/".
           02 edt-dy            pic  9(02).
           02                   pic  x(01)  value "/".
           02 edt-cn            pic  9(02).
           02 edt-yr            pic  9(02).
                                                              
       01  edt-time.
           02 edt-hr            pic  9(02).
           02                   pic  x(01)  value ":".
           02 edt-mn            pic  9(02).
           02                   pic  x(01)  value ":".
           02 edt-sc            pic  9(02).
           02 edt-mr            pic  x(02).                   
/
       01  edt-sngl-mult        pic  x(15).
       01  edt-name-tp1         pic  x(40).
       01  edt-name-tp2         pic  x(40).
       01  edt-rcd-ch           pic  x(30).                           
       01  edt-clctn-ch         pic  x(30).
       01  edt-clctn-acct-no    pic  x(15).
       01  edt-clctn-bank-name  pic  x(15).
       01  edt-doc-dsc          pic  x(30).                            
       01  edt-clrk-name        pic  x(30).
       01  edit-file-nmbr       pic  z(08). 
       01  edt-doc-no           pic  99b99b99b999b99999. 
       01  edt-amount           pic  zzzz,zz9.99.
       01  edt-ttax             pic  zzzz,zz9.99.
       01  edt-file-no          pic  zzzzzzz9.
       01  edit-file-nmbr-alpa	redefines
	   edt-file-no		pic  x(01) occurs 8 times
				     indexed by ef-ix.
       01  edit-book            pic  zzzzz9.     
       01  edit-page-bgin       pic  zzzzz9.
       01  edit-page-endg       pic  zzzzz9.       
       01  book-byte-cntr       pic  9(02).
       01  page-bgin-byte-cntr  pic  9(02).  
       01  page-endg-byte-cntr  pic  9(02).
       01  book-lent            pic  9(02).
       01  page-bgin-lent       pic  9(02).
       01  page-endg-lent       pic  9(02).
       01  void-page-cntr	pic  9(04).
       01  void-item-cntr	pic  9(04).
       01  edit-void-page-cntr  pic  z(04).
       01  edit-begn-book       pic  z(04).
/
       01  file-info.                *> used for cbl_check_file_exist call
           02 file-detl.                           *> file details
              03 file-size      pic  x(08) comp-x. *> file size
              03 file-date.                        *> file created date
                 04 file-day    pic  x(01) comp-x. *> file created day
                 04 file-mnth   pic  x(01) comp-x. *> file created month
                 04 file-year   pic  x(02) comp-x. *> file created year
              03 file-time.
                 04 file-hour   pic  x(01) comp-x. *> file created hour
                 04 file-min    pic  x(01) comp-x. *> file created minute
                 04 file-sec    pic  x(01) comp-x. *> file created seconds
                 04 file-hdth   pic  x(01) comp-x. *> file created hundredths
       01  dymo-file-nam1       pic  x(33) value "C:\Progra~2\DYMO\DYMOLa~1\dls.exe".
       01  dymo-file-nam2       pic  x(33) value "C:\Progra~1\DYMO\DYMOLa~1\dls.exe".
       01  dymo-flag            pic  x(01) value space.  *> Is Dymo LabelWriter 450 turbo software installed?
       01  stts-code            pic  9(02) comp-5.

       01  edit-pags            pic  z(03).
       01  edit-pags-byte-pntr  pic  9(01).
       01  edit-pags-desc       pic  x(03).
       01  edit-pags-lent       pic  9(01).
                                                        
       01  julian-date          pic  9(05).
       01                       redefines
           julian-date.                                            
           02 julian-year       pic  9(02).
           02 julian-day        pic  9(05).

       01  ws-receipt-no        pic  9(09).
       01  ws-offc-name         pic  x(30).
       01  ws-offcl-name        pic  x(30).
       01  ws-offcl-title       pic  x(30).
       01  ws-payment-no        pic  9(04).
*      01  ws-rcpt-no           pic  9(09).
       01  ws-no-pages          pic s9(07).
       01  ws-addl-pg-amt       pic s9(07)v99.
       01  ws-afrd-hous         pic s9(02)v99.
       01  ws-clrk-fees         pic s9(07)v99.
       01  ws-stat-fees         pic s9(07)v99.
       01  ws-rcd-fee           pic s9(07)v99.
       01  ws-addl-pg-fee       pic s9(07)v99.
       01  ws-pstg-fee          pic s9(07)v99.
       01  ws-pnly-fee          pic s9(07)v99.
       01  ws-addl-fee          pic s9(07)v99.
       01  ws-trnsf-tax         pic s9(07)v99.
       01  ws-trnsf-tax-flg     pic  x(01).
       01  ws-chng-or-due-titl  pic  x(20).
       01  ws-mult-amt-due      pic s9(07)v99.
       01  ws-mult-doc-cnt      pic  9(05).
       01  tmp-amt-due          pic s9(07)v99.
       01  ws-mp-amt-due        pic s9(07)v99.
       01  ws-mp-amt-recd       pic s9(07)v99.
       01  ws-mp-pay-tp1        pic  x(01).
       01  ws-mp-pay-tp2        pic  x(01).
       01  ws-mp-pay-tp3        pic  x(01).
       01  ws-mp-pay-tp4        pic  x(01).
       01  ws-mp-pay-amt1       pic s9(07)v99.
       01  ws-mp-pay-amt2       pic s9(07)v99.
       01  ws-mp-pay-amt3       pic s9(07)v99.
       01  ws-mp-pay-amt4       pic s9(07)v99.
       01  ws-mp-amt-paid       pic s9(07)v99.
       01  ws-mp-chk-no1        pic  x(16).
       01  ws-mp-chk-no2        pic  x(16).
       01  ws-mp-chk-no3        pic  x(16).
       01  ws-mp-chk-no4        pic  x(16).
       01  ws-mp-change         pic s9(07)v99.
       01  ws-fml1-dir          pic  x(25).
       01  ws-fml2-dir          pic  x(25).
       01  ws-frst              pic  x(25).
       01  ws-midl              pic  x(25).
       01  ws-last              pic  x(25).
       01  ws-nam1              pic  x(75).
       01  ws-nam2              pic  x(75).

       01  ws-valuation         pic  9(10)v99.
       01                       redefines
           ws-valuation.
           02 ws-val-1          pic  9(07).
           02 ws-val-2          pic  9(03)v99.

       01  ws-nam.
           02 ws-byt            pic  x(01) occurs 75 times indexed by wb-ix.
/
       01  ws-pay-flds.
           02  ws-amt-recd      pic s9(10)v99.
           02  ws-change        pic s9(10)v99.

           02  ws-pay-tp1       pic  x(01).
           02  ws-pay-tp2       pic  x(01).
           02  ws-pay-tp3       pic  x(01).
           02  ws-pay-tp4       pic  x(01).
           02  ws-pay-tp5       pic  x(01).
           02  ws-pay-tp6       pic  x(01).
           02  ws-pay-tp7       pic  x(01).
           02  ws-pay-tp8       pic  x(01).
           02  ws-pay-tp9       pic  x(01).
           02  ws-pay-tp10      pic  x(01).
           02  ws-pay-tp11      pic  x(01).
           02  ws-pay-tp12      pic  x(01).
           02  ws-pay-tp13      pic  x(01).
           02  ws-pay-tp14      pic  x(01).
           02  ws-pay-tp15      pic  x(01).
           02  ws-pay-tp16      pic  x(01).

           02  ws-pay-amt1      pic s9(07)v99.
           02  ws-pay-amt2      pic s9(07)v99.
           02  ws-pay-amt3      pic s9(07)v99.
           02  ws-pay-amt4      pic s9(07)v99.
           02  ws-pay-amt5      pic s9(07)v99.
           02  ws-pay-amt6      pic s9(07)v99.
           02  ws-pay-amt7      pic s9(07)v99.
           02  ws-pay-amt8      pic s9(07)v99.
           02  ws-pay-amt9      pic s9(07)v99.
           02  ws-pay-amt10     pic s9(07)v99.
           02  ws-pay-amt11     pic s9(07)v99.
           02  ws-pay-amt12     pic s9(07)v99.
           02  ws-pay-amt13     pic s9(07)v99.
           02  ws-pay-amt14     pic s9(07)v99.
           02  ws-pay-amt15     pic s9(07)v99.
           02  ws-pay-amt16     pic s9(07)v99.

           02  ws-chk-no1       pic  x(16).
           02  ws-chk-no2       pic  x(16).
           02  ws-chk-no3       pic  x(16).
           02  ws-chk-no4       pic  x(16).
           02  ws-chk-no5       pic  x(16).
           02  ws-chk-no6       pic  x(16).
           02  ws-chk-no7       pic  x(16).
           02  ws-chk-no8       pic  x(16).
           02  ws-chk-no9       pic  x(16).
           02  ws-chk-no10      pic  x(16).
           02  ws-chk-no11      pic  x(16).
           02  ws-chk-no12      pic  x(16).
           02  ws-chk-no13      pic  x(16).
           02  ws-chk-no14      pic  x(16).
           02  ws-chk-no15      pic  x(16).
           02  ws-chk-no16      pic  x(16).
/
           02  edt-pay-tp1      pic  x(10).
           02  edt-pay-tp2      pic  x(10).
           02  edt-pay-tp3      pic  x(10).
           02  edt-pay-tp4      pic  x(10).
           02  edt-pay-tp5      pic  x(10).
           02  edt-pay-tp6      pic  x(10).
           02  edt-pay-tp7      pic  x(10).
           02  edt-pay-tp8      pic  x(10).
           02  edt-pay-tp9      pic  x(10).
           02  edt-pay-tp10     pic  x(10).
           02  edt-pay-tp11     pic  x(10).
           02  edt-pay-tp12     pic  x(10).         
           02  edt-pay-tp13     pic  x(10).
           02  edt-pay-tp14     pic  x(10).
           02  edt-pay-tp15     pic  x(10).
           02  edt-pay-tp16     pic  x(10).

       01  dt-prnt.
           02	 		pic  x(04).
           02 dt-line.
              03 dt-title       pic  x(20).
              03                pic  x(02).                       
              03 dt-desc        pic  x(35).
           02 dt-line-0002      redefines
              dt-line.
              03 dt-dcmt-nmbr   pic  99b99b99b999b99999.
              03                pic  x(02).
              03 dt-dcmt-type   pic  x(10).
              03                pic  x(01).
              03 dt-amnt-due    pic  zzz,zzz.zz.
              03                pic  x(16).
                                                                                  
       01  detl-itca-line.                                         
           02 detl-itca-titl    pic  x(15).
           02                   pic  x(02).
           02 detl-itca-desc    pic  x(23).
                                                                                 
       01  lasr-rcpt-sttn	pic  x(01) value space.
       01  line-nmbr            pic  9(02).
       01  n-fld-1.
           02 n1-byt            pic  x(01) occurs 20 times indexed by n1-ix.

       01  n-fld-2.
           02 n2-byt            pic  x(01) occurs 20 times indexed by n2-ix.

       01  n-fld-3.
           02 n3-byt            pic  x(01) occurs 20 times indexed by n3-ix.

       01  n-fld-4.
           02 n4-byt            pic  x(01) occurs 20 times indexed by n4-ix.

       01  n-fld-5.
           02 n5-byt            pic  x(01) occurs 20 times indexed by n5-ix.

       01  n-fld-6.
           02 n6-byt            pic  x(01) occurs 20 times indexed by n6-ix.
/
       01  n-fld-7.
           02 n7-byt            pic  x(01) occurs 20 times indexed by n7-ix.

       01  n-fld-8.
           02 n8-byt            pic  x(01) occurs 20 times indexed by n8-ix.

       01  caps-lock-1          pic  9(02) comp-x value 01.
       01  caps-lock-2.
           02                   pic  9(02) comp-x value 01.
           02                   pic  9(01)        value 02.
           02                   pic  9(02) comp-x value 85.
           02                   pic  9(02) comp-x value 01.

       01  crt-status.
           02 crt-s1            pic  9(01).
           02 crt-s2            pic  9(02) comp-x.
           02 crt-s3            pic  9(02) comp-x.

       01  sys-date.
           02 sys-yr            pic  9(02).
           02 sys-mt            pic  9(02).
           02 sys-dy            pic  9(02).

       01  sys-time.
           02 sys-hr            pic  9(02).
           02 sys-mn            pic  9(02).
           02 sys-sc            pic  9(02).
           02 sys-tn            pic  9(02).

       01  dh-ln                pic  x(78).
       01  sh-ln                pic  x(78).
       01  vt-chr               pic  x(01).
       01  ln-no                pic  9(02).
       01  cl-no                pic  9(02).
/
       01  spec-valu.
           02                   pic  9(02) comp-x value 007.
           02                   pic  9(02) comp-x value 011.
           02                   pic  9(02) comp-x value 012.
           02                   pic  9(02) comp-x value 017.
           02                   pic  9(02) comp-x value 018.
           02                   pic  9(02) comp-x value 019.
           02                   pic  9(02) comp-x value 020.
           02                   pic  9(02) comp-x value 024.
           02                   pic  9(02) comp-x value 025.
           02                   pic  9(02) comp-x value 026.
           02                   pic  9(02) comp-x value 027.
           02                   pic  9(02) comp-x value 043.
           02                   pic  9(02) comp-x value 179.
           02                   pic  9(02) comp-x value 182.
           02                   pic  9(02) comp-x value 185.
           02                   pic  9(02) comp-x value 186.
           02                   pic  9(02) comp-x value 187.
           02                   pic  9(02) comp-x value 188.
           02                   pic  9(02) comp-x value 189.
           02                   pic  9(02) comp-x value 193.
           02                   pic  9(02) comp-x value 194.
           02                   pic  9(02) comp-x value 196.
           02                   pic  9(02) comp-x value 199.
           02                   pic  9(02) comp-x value 200.
           02                   pic  9(02) comp-x value 201.
           02                   pic  9(02) comp-x value 204.
           02                   pic  9(02) comp-x value 205.
           02                   pic  9(02) comp-x value 207.
       01                       redefines
           spec-valu.
           02 chr-07            pic  x(01).                         
           02 chr-11            pic  x(01).
           02 chr-12            pic  x(01).
           02 chr-17            pic  x(01).
           02 chr-18            pic  x(01).
           02 chr-19            pic  x(01).
           02 chr-20            pic  x(01).
           02 chr-24            pic  x(01).
           02 chr-25            pic  x(01).
           02 chr-26            pic  x(01).
           02 chr-27            pic  x(01).
           02 chr-43            pic  x(01).
           02 chr-179           pic  x(01).
           02 chr-182           pic  x(01).
           02 chr-185           pic  x(01).
           02 chr-186           pic  x(01).
           02 chr-187           pic  x(01).
           02 chr-188           pic  x(01).
           02 chr-189           pic  x(01).
           02 chr-193           pic  x(01).
           02 chr-194           pic  x(01).
           02 chr-196           pic  x(01).
           02 chr-199           pic  x(01).
           02 chr-200           pic  x(01).
           02 chr-201           pic  x(01).
           02 chr-204           pic  x(01).
           02 chr-205           pic  x(01).
           02 chr-207           pic  x(01).

       01  dflt-sqnc.
           02                   pic  x(01) value x'1b'.
           02                   pic  x(01) value "E".
                                                                             
       01  font-sqnc.           
           02                   pic  x(01) value x'1b'.
           02                   pic  x(04) value "(10U".              
           02                   pic  x(01) value x'1b'.
           02                   pic  x(04) value "(s0p".
           02 font-ptch         pic  9(02) value 14.
           02                   pic  x(10) value "h0s0b4099T".
                                
       01  spac-sqnc.           
           02                   pic  x(01) value x'1b'.
           02                   pic  x(02) value "&l".
           02 spac-nmbr         pic  9(01) value 07.
           02                   pic  x(01) value "C".

       01  file-ltrl.
           02                   pic  x(14) value "(Feefile.dat )".
           02                   pic  x(14) value "(Ixcdfile.dat)".
           02                   pic  x(14) value "(Multitmp.dat)".
           02                   pic  x(14) value "(Feercpt.dat )".
           02                   pic  x(14) value "(feesjrnl.dat)".
           02                   pic  x(14) value "(indxcode.dat)".
           02                   pic  x(14) value "(notary.dat  )".
           02                   pic  x(14) value "(deedlist.dat)".        
           02                   pic  x(14) value "(dcmtxref.dat)".
           02                   pic  x(14) value "(filexrf.dat )".
       01  file-name            redefines
           file-ltrl            pic  x(14) occurs 10 times.
       01  file-nmbr-deed-list  pic  9(02) value 08.
       01  file-nmbr-dcmt-xref  pic  9(02) value 09.
       01  file-nmbr-fil-xrf    pic  9(02) value 10.    
       
       
   *>--- Excel Parameters ---                                       
 01  ExcelObject                object reference.
 01  WorkBooksCol               object reference.
 01  WorkBook                   object reference.                               
 01  Sheets                     object reference.                    
 01  Sheet                      object reference.
 01  Cell                       object reference.
 01  CellRange                  object reference.                 
 01  rows                       pic  9(03) comp-5.        
 01  clmn                       pic  9(03) comp-5.                         
 01  xcel-cell                  pic  x(10).
 01  xcel-cell-byte             redefines
     xcel-cell                  pic  x(01) occurs 10 times
                                            indexed by xc-ix.
 01  xcel-file-path             pic  x(38) value
 "\\kcffil01\clk\dat\void.xls".
 01  cell-valu                  pic  x(100).        *> excel cell value
 01  rows-cntr                  pic  9(03) comp-5.
 01  clmn-cntr                  pic  9(03) comp-5.
 
 01  xcel-path			pic  x(27) value "c:\temp\void.xls".
 01  edit-amnt                  pic  $,$$$,$$9.99.
     
 *>--  End of Excel Parameters ---                              
 01  wait-loop-cntr		pic 9(02). 		      
 01  curr-time.                                                     
     02          		pic 9(04).
     02 curr-secs		pic 9(02).
     02             		pic 9(02).
 01  prev-secs			pic 9(02).
 01  wait-maxm-cntr		pic 9(02).                                                                     
 01  term-chck			pic x(01).

 
       linkage section.                                                 
                                                   
       01  user-name            pic  x(10).
       01  user-levl            pic  x(02).
       01  sttn-nmbr            pic  9(02).
       01  prtr-name            pic  x(60).
       01  swch-nmbr            pic  x(01) occurs 08 times.
/
       screen section.

       01  scrn-hedr.
           02                             highlight
                                          background-color 02
                                          foreground-color 07.
             03 "fee                 "    line  01     col 01.
             03 "                                         ".
             03 "                    ".

       01  scrn-body.   
           02                             lowlight
                                          background-color 03
                                          foreground-color 00.
             03               pic x(1920) from  blnk-line
                                          line  02     col 01.

       01  scrn-warn.
           02                             lowlight
                                          background-color 07
                                          foreground-color 00.
             03  "                                        "
                                          line  10     col 20.
             03  "  Please call Eddie and Sevie before    "
                                          line  11     col 20.
             03  "  running this program.  We want to be  "
                                          line  12     col 20.
             03  "  sure it has been correctly modified.  "
                                          line  13     col 20.
             03  "                                       "
                                          line  14     col 20.
             03 scrn-warn-okay  pic  x(01) using kybd-okay.

       01  ss-dflt                        highlight                 
                                          blank screen
                                          background-color 01
                                          foreground-color 07.

       01  ss-brdr                        highlight.
           02                             background-color 01
                                          foreground-color 07.
             03                 pic x(01) from  chr-201
                                          line  01    col 01.
             03                 pic x(78) from  dh-ln.
             03                 pic x(01) from  chr-187.
             03                 pic x(01) from  chr-199
                                          line  03     col 01.
             03                 pic x(78) from  sh-ln.
             03                 pic x(01) from  chr-182.
             03                 pic x(01) from  chr-199
                                          line  21     col 01.
             03                 pic x(78) from  sh-ln.
             03                 pic x(01) from  chr-182.
             03                 pic x(01) from  chr-200
                                          line  24     col 01.
             03                 pic x(78) from  dh-ln.
             03                 pic x(01) from  chr-188.
             03                 pic x(01) from  chr-194
                                          line  21     col 70.
             03                 pic x(01) from  chr-207
                                          line  24     col 70.

       01  ss-vrt-ln                      highlight.
           02                             background-color 01
                                          foreground-color 07.
             03 ss-vrt          pic x(01) from  vt-chr
                                          line  ln-no
                                          col   cl-no.
/
       01  ss-hedr                        highlight.
           02                             background-color 06
                                          foreground-color 06.

             03 ss-date.
                04              pic 9(02) from  sys-mt
                                          line  02     col 02.
                04 "/".
                04              pic 9(02) from  sys-dy.
                04 "/".
                04              pic 9(02) from  sys-yr.
             03 "   fee  ver 3.5 ".
             03 "     ".
             03 "Index System Fee Entry".
             03 "      ".
             03 ss-user         pic 9(02) from  sttn-nmbr.
             03 "       ".
             03 ss-tim.
                04              pic 9(02) from  sys-hr.
                04 ":".
                04              pic 9(02) from  sys-mn.                 
                04 ":".
                04              pic 9(02) from  sys-sc.
                04 "-".
                04              pic x(01) from  sys-mrd.
             03 " ".

       01  ss-clk-titls                    highlight
                                           background-color 01
                                           foreground-color 02.
           02 "Enter Clerk Id"             line  10     col 05.
           02 "__________"                 line  10     col 30.

       01  ss-clk-id                       highlight
                                           background-color 01
                                           foreground-color 07.
           02 ss-clk            pic x(10)  using  kb-clk-id
                                           secure
                                           prompt
                                           line  10     col 30.

       01  ss-clctn-ch                     highlight.
           02                              background-color 01
                                           foreground-color 02.
              03 "Collection Lctn"         line  13     col 05.
           02                              background-color 01
                                           foreground-color 07.
              03 ss-ch          pic x(01)  using kb-clctn-ch
                                           line  13     col 30.
              03                pic x(30)  from  edt-clctn-ch
                                           line  13     col 45.
/
       01  ss-fee-titls                    highlight
                                           background-color 01
                                           foreground-color 02.
           02 "Single/Multi"               line  04     col 03.
           02                              background-color 07
                                           foreground-color 00.
              03 "ESCape"                  line  04     col 50.

           02                              background-color 07
                                           foreground-color 06.
              03 "ESC"                     line  04     col 50.
           02 "Document No."               line  05     col 03.
           02 "Date"                       line  04     col 63.
           02 "Time"                       line  05     col 63.
           02 "Business/persn"             line  06     col 03.
           02 "Business/persn"             line  08     col 03.
           02 "Bk location"                line  10     col 03.
           02 "Document Type"              line  11     col 03.
           02 "Begin Book/Pg"              line  12     col 45
                                           background-color 05
                                           foreground-color 03.
           02 "Ending Book/Pg"             line  12     col 65
                                           background-color 05
                                           foreground-color 03.
           02 "No of Pages"                line  12     col 03.
           02 "Valuation"                  line  13     col 03.
           02 "Recrdng Fee"                line  14     col 03.
           02 "Addtnl pgs "                line  15     col 03.
           02 "Postage Fee"                line  16     col 03.
           02 "Transfr Tax"                line  17     col 03.
           02 "Addtnl  Fee"                line  18     col 03.
           02 "Penalty Fee"                line  19     col 03.
           02                    pic x(11) from  sh-ln
                                           size  11
                                           line  19     col 18.
           02 "Amount Due"                 line  20     col 03.            

       01  ss-f7                           highlight.
           02                              background-color 07
                                           foreground-color 00.
              03 "F7 Multi Payoff"         line  05     col 41.

           02                              background-color 07
                                           foreground-color 06.
              03 "F7"                      line  05     col 41.

       01  ss-fee-pay-titls                highlight
                                           background-color 01
                                           foreground-color 02.
           02 "Pay Type"                   line  14     col 35.
           02 "Payment Amt"                line  14     col 48.
           02 "Check/Card #"               line  14     col 63.
           02 "Amount Recd"                line  20     col 35.
           02                    pic x(11) from  sh-ln
                                           size  11
                                           line  19     col 48.

       01  ss-mp-fee-pay-titls             highlight
                                           background-color 03
                                           foreground-color 06.
           02 "Pay Type"                   line  04     col 35.
           02 "Payment Amt"                line  04     col 48.
           02 "Check/Card #"               line  04     col 63.
           02 "Amount Recd"                line  20     col 35.
           02                   pic x(11)  from  sh-ln
                                           size  11
                                           line  19     col 48.
/
       01  ss-sm-titl                      highlight.

           02                              background-color 01
                                           foreground-color 07.
              03 "                   "     line  04     col 31.
           02                              background-color 07
                                           foreground-color 00.
              03 "Single Multi"            line  04     col 31.
           02                              background-color 07
                                           foreground-color 06.
              03 "S"                       line  04     col 31.
              03 "M"                       line  04     col 38.
           02                              background-color 07
                                           foreground-color 00.
              03               pic  x(01)  from  chr-179
                                           line  04     col 37.

       01  ss-bp1-titl                     highlight.
           02                              background-color 07
                                           foreground-color 00.
              03 "Person Business"         line  06     col 31.

           02                              background-color 01
                                           foreground-color 00.
              03 "                              "
                                           line  06     col 46.

           02                              background-color 07
                                           foreground-color 06.
              03 "P"                       line  06     col 31.
              03 "B"                       line  06     col 38.
           02                              background-color 07
                                           foreground-color 00.
              03               pic  x(01)  from chr-179
                                           line  06     col 37.

       01  ss-bp2-titl                     highlight.
           02                              background-color 07
                                           foreground-color 00.
              03 "Person Business"         line  08     col 31.

           02                              background-color 01
                                           foreground-color 00.
              03 "                              "
                                           line  08     col 46.
           02                              background-color 07
                                           foreground-color 06.
              03 "P"                       line  08     col 31.
              03 "B"                       line  08     col 38.
           02                              background-color 07
                                           foreground-color 00.
              03               pic  x(01)  from  chr-179
                                           line  08     col 37.
/
       01  ss-edt-file-no                  highlight.
           02                              background-color 01
                                           foreground-color 03.

           02 " File Number "              line  12     col 45
                                           background-color 05
                                           foreground-color 03.
           02 "                "           line  12     col 63
                                           background-color 01
                                           foreground-color 03.
           02                              background-color 01
                                           foreground-color 03.
              03                 pic x(35) line  13     col 45.
              03  ss-file-no     pic zzzzzzzzzzz9
                                           using fr-file-no
                                           line  13     col 45.                           
/
       01  ss-fee-data                     highlight.
           02 ss-sngl-mult       pic x(01) using kb-sngl-mult
                                           line  04     col 20.           
           02 ss-edt-sngl-mult   pic x(15) from  edt-sngl-mult
                                           background-color 01
                                           foreground-color 06
                                           line  04     col 31.
           02 ss-key             pic z(14) using fr-doc-no
                                           line  05     col 20.
           02                    pic x(10) from  edt-date
                                           line  04     col 69.
           02                    pic x(11) from  edt-time
                                           line  05     col 69.
           02                    pic x(17) using edt-clrk-name
                                           line  10     col 63.
           02                    pic x(17) using edt-clctn-ch
                                           line  11     col 63.
           02                    pic 9(02) from  sttn-nmbr
                                           line  11     col 78.
           02 ss-fld-3           pic x(01) using fr-name-tp1  auto
                                           line  06     col 20.
           02 ss-edt-3           pic x(40) from  edt-name-tp1
                                           background-color 01
                                           foreground-color 06
                                           line  06     col 31.
           02 ss-fld-4           pic x(75) using fr-name1     auto
                                           line  07     col 04.
           02 ss-fld-5           pic x(01) using fr-name-tp2  auto
                                           line  08     col 20.
           02 ss-edt-5           pic x(40) from  edt-name-tp2
                                           background-color 01
                                           foreground-color 06
                                           line  08     col 31.
           02 ss-fld-6           pic x(75) using fr-name2     auto
                                           line  09     col 04.
           02 ss-fld-1           pic x(01) using fr-rcd-ch    auto
                                           line  10     col 20.
           02 ss-edt-1           pic x(30) using edt-rcd-ch
                                           background-color 01
                                           foreground-color 06
                                           line  10     col 31.
/
           02 ss-fld-2           pic x(10) using fr-doc-tp
                                           line  11     col 20.
           02 ss-edt-2           pic x(30) from  edt-doc-dsc
                                           background-color 01
                                           foreground-color 06
                                           line  11     col 31.
           02 ss-fld-7           pic z(04) using fr-no-pages  auto
                                           line  12     col 20.
           02 ss-edt-7                     background-color 01
                                           foreground-color 03.
              03                 pic zzzzz9
                                           from  fr-beg-bk
                                           line  13     col 45.
              03 "/"                       line  13     col 51.
              03                 pic zzzzz9
                                           from  fr-beg-pg
                                           line  13     col 52.
              03                 pic zzzzz9
                                           from  fr-end-bk
                                           line  13     col 65.
              03 "/"                       line  13     col 71.
              03                 pic zzzzz9
                                           from  fr-end-pg
                                           line  13     col 72.
           02 ss-fld-8           pic zzz,zzz,zzz.zz
                                           using ws-valuation auto
                                           line  13     col 18.
           02 ss-fee-amts.
              03 ss-rcd-fees.
                 04 ss-fld-9     pic zzzz,zz9.99
                                           using fr-rcd-fee     auto
                                           line  14     col 18.
                 04 ss-fld-10    pic zzzz,zz9.99
                                           using fr-addl-pg-fee auto
                                           line  15     col 18.
                 04 ss-fld-11    pic zzzz,zz9.99
                                           using fr-pstg-fee    auto
                                           line  16     col 18.
                 04 ss-fld-12    pic zzzz,zz9.99
                                           using fr-trnsf-tax   auto
                                           line  17     col 18.
                 04 ss-fld-13    pic zzzz,zz9.99-
                                           using fr-addl-fee    auto
                                           line  18     col 18.
                 04 ss-fld-13a   pic zzzz,zz9.99
                                           using fr-pnly-fee    auto
                                           line  19     col 18.
                 04              pic zzzz,zz9.99
                                           from  fr-amt-due     auto
                                           line  20     col 18
                                           background-color 05
                                           foreground-color 03.
/
              03 ss-pay-flds.
                 04              pic zzzz,zzz.zz
                                           from  fr-amt-recd
                                           line  20     col 48.
                 04              pic x(13) from  ws-chng-or-due-titl
                                           line  19     col 65.
                 04              pic zzzzzz,zz9.99
                                           from  ws-change
                                           line  20     col 65.
                 04 ss-fld-14    pic x(01) using ws-pay-tp1
                                           line  15     col 35.
                 04 ss-edt-14    pic x(10) from  edt-pay-tp1
                                           background-color 01
                                           foreground-color 06
                                           line  15     col 37.
                 04 ss-fld-15    pic zzzz,zzz.zz
                                           using ws-pay-amt1    auto
                                           line  15     col 48.
                 04 ss-fld-16    pic x(16) using ws-chk-no1     auto
                                           line  15     col 63.
                 04 ss-fld-17    pic x(01) using ws-pay-tp2     auto
                                           line  16     col 35.
                 04 ss-edt-17    pic x(10) from  edt-pay-tp2    auto
                                           background-color 01
                                           foreground-color 06
                                           line  16     col 37.
                 04 ss-fld-18    pic zzzz,zzz.zz
                                           using ws-pay-amt2    auto
                                           line  16     col 48.
                 04 ss-fld-19    pic x(16) using ws-chk-no2     auto
                                           line  16     col 63.
                 04 ss-fld-20    pic x(01) using ws-pay-tp3     auto
                                           line  17     col 35.
                 04 ss-edt-20    pic x(10) from  edt-pay-tp3
                                           background-color 01
                                           foreground-color 06
                                           line  17     col 37.
                 04 ss-fld-21    pic zzzz,zzz.zz
                                           using ws-pay-amt3    auto
                                           line  17     col 48.
                 04 ss-fld-22    pic x(16) using ws-chk-no3     auto
                                           line  17     col 63.
                 04 ss-fld-23    pic x(01) using ws-pay-tp4     auto
                                           line  18     col 35.
                 04 ss-edt-23    pic x(10) from  edt-pay-tp4
                                           background-color 01
                                           foreground-color 06
                                           line  18     col 37.
                 04 ss-fld-24    pic zzzz,zzz.zz
                                           using ws-pay-amt4    auto
                                           line  18     col 48.
                 04 ss-fld-25    pic x(16) using ws-chk-no4     auto
                                           line  18     col 63.
           02 ss-ok              pic x(01) using kb-ok          auto
                                           line  22     col 45.
/
       01 ss-mp-data                       highlight.
              03 ss-mp-amt-due.
                 04              pic zzzz,zz9.99
                                           from  ws-amt-recd
                                           line  20     col 48.
                 04              pic x(13) from  ws-chng-or-due-titl
                                           line  19     col 65.
                 04              pic zzzzzz,zz9.99
                                           from  ws-change
                                           line  20     col 65.
              03 ss-mp-pay-flds.
                 04 ss-mp-fld-14 pic x(01) using ws-pay-tp1
                                           line  05     col 35.
                 04 ss-mp-edt-14 pic x(10) from  edt-pay-tp1
                                           background-color 01
                                           foreground-color 06
                                           line  05     col 37.
                 04 ss-mp-fld-15 pic zzzz,zzz.zz
                                           using ws-pay-amt1    auto
                                           line  05     col 48.
                 04 ss-mp-fld-16 pic x(16) using ws-chk-no1     auto
                                           line  05     col 63.

                 04 ss-mp-fld-17 pic x(01) using ws-pay-tp2     auto
                                           line  06     col 35.
                 04 ss-mp-edt-17 pic x(10) from  edt-pay-tp2    auto
                                           background-color 01
                                           foreground-color 06
                                           line  06     col 37.
                 04 ss-mp-fld-18 pic zzzz,zzz.zz
                                           using ws-pay-amt2    auto
                                           line  06     col 48.
                 04 ss-mp-fld-19 pic x(16) using ws-chk-no2     auto
                                           line  06     col 63.
                 04 ss-mp-fld-20 pic x(01) using ws-pay-tp3     auto
                                           line  07     col 35.
                 04 ss-mp-edt-20 pic x(10) from  edt-pay-tp3
                                           background-color 01
                                           foreground-color 06
                                           line  07     col 37.
                 04 ss-mp-fld-21 pic zzzz,zzz.zz
                                           using ws-pay-amt3    auto
                                           line  07     col 48.                          
                 04 ss-mp-fld-22 pic x(16) using ws-chk-no3     auto
                                           line  07     col 63.
                 04 ss-mp-fld-23 pic x(01) using ws-pay-tp4     auto
                                           line  08     col 35.
                 04 ss-mp-edt-23 pic x(10) from  edt-pay-tp4
                                           background-color 01
                                           foreground-color 06
                                           line  08     col 37.
                 04 ss-mp-fld-24 pic zzzz,zzz.zz
                                           using ws-pay-amt4    auto
                                           line  08     col 48.
                 04 ss-mp-fld-25 pic x(16) using ws-chk-no4     auto
                                           line  08     col 63.

                 04 ss-mp-fld-26 pic x(01) using ws-pay-tp5     auto
                                           line  09     col 35.
                 04 ss-mp-edt-26 pic x(10) from  edt-pay-tp5
                                           background-color 01
                                           foreground-color 06
                                           line  09     col 37.
                 04 ss-mp-fld-27 pic zzzz,zzz.zz
                                           using ws-pay-amt5    auto
                                           line  09     col 48.
                 04 ss-mp-fld-28 pic x(16) using ws-chk-no5     auto
                                           line  09     col 63.
                 04 ss-mp-fld-29 pic x(01) using ws-pay-tp6     auto
                                           line  10     col 35.
                 04 ss-mp-edt-29 pic x(10) from  edt-pay-tp6
                                           background-color 01
                                           foreground-color 06
                                           line  10     col 37.
                 04 ss-mp-fld-30 pic zzzz,zzz.zz
                                           using ws-pay-amt6    auto
                                           line  10     col 48.
                 04 ss-mp-fld-31 pic x(16) using ws-chk-no6     auto
                                           line  10     col 63.

                 04 ss-mp-fld-32 pic x(01) using ws-pay-tp7     auto
                                           line  11     col 35.
                 04 ss-mp-edt-32 pic x(10) from  edt-pay-tp7
                                           background-color 01
                                           foreground-color 06
                                           line  11     col 37.
                 04 ss-mp-fld-33 pic zzzz,zzz.zz
                                           using ws-pay-amt7    auto
                                           line  11     col 48.
                 04 ss-mp-fld-34 pic x(16) using ws-chk-no7     auto
                                           line  11     col 63.
                 04 ss-mp-fld-35 pic x(01) using ws-pay-tp8     auto
                                           line  12     col 35.
                 04 ss-mp-edt-35 pic x(10) from  edt-pay-tp8
                                           background-color 01
                                           foreground-color 06
                                           line  12     col 37.
                 04 ss-mp-fld-36 pic zzzz,zzz.zz
                                           using ws-pay-amt8    auto
                                           line  12     col 48.
                 04 ss-mp-fld-37 pic x(16) using ws-chk-no8     auto
                                           line  12     col 63.

                 04 ss-mp-fld-38 pic x(01) using ws-pay-tp9     auto
                                           line  13     col 35.
                 04 ss-mp-edt-38 pic x(10) from  edt-pay-tp9
                                           background-color 01
                                           foreground-color 06
                                           line  13     col 37.
                 04 ss-mp-fld-39 pic zzzz,zzz.zz
                                           using ws-pay-amt9    auto
                                           line  13     col 48.
                 04 ss-mp-fld-40 pic x(16) using ws-chk-no9     auto
                                           line  13     col 63.
                 04 ss-mp-fld-41 pic x(01) using ws-pay-tp10    auto
                                           line  14     col 35.
                 04 ss-mp-edt-41 pic x(10) from  edt-pay-tp10
                                           background-color 01
                                           foreground-color 06
                                           line  14     col 37.
                 04 ss-mp-fld-42 pic zzzz,zzz.zz
                                           using ws-pay-amt10   auto
                                           line  14     col 48.
                 04 ss-mp-fld-43 pic x(16) using ws-chk-no10    auto
                                           line  14     col 63.

                 04 ss-mp-fld-44 pic x(01) using ws-pay-tp11    auto
                                           line  15     col 35.
                 04 ss-mp-edt-44 pic x(10) from  edt-pay-tp11
                                           background-color 01
                                           foreground-color 06
                                           line  15     col 37.
                 04 ss-mp-fld-45 pic zzzz,zzz.zz
                                           using ws-pay-amt11   auto
                                           line  15     col 48.
                 04 ss-mp-fld-46 pic x(16) using ws-chk-no11    auto
                                           line  15     col 63.
                 04 ss-mp-fld-47 pic x(01) using ws-pay-tp12    auto
                                           line  16     col 35.
                 04 ss-mp-edt-47 pic x(10) from  edt-pay-tp12
                                           background-color 01
                                           foreground-color 06
                                           line  16     col 37.
                 04 ss-mp-fld-48 pic zzzz,zzz.zz
                                           using ws-pay-amt12   auto
                                           line  16     col 48.
                 04 ss-mp-fld-49 pic x(16) using ws-chk-no12    auto
                                           line  16     col 63.

                 04 ss-mp-fld-50 pic x(01) using ws-pay-tp13    auto
                                           line  17     col 35.
                 04 ss-mp-edt-50 pic x(10) from  edt-pay-tp13
                                           background-color 01
                                           foreground-color 06
                                           line  17     col 37.
                 04 ss-mp-fld-51 pic zzzz,zzz.zz
                                           using ws-pay-amt13   auto
                                           line  17     col 48.
                 04 ss-mp-fld-52 pic x(16) using ws-chk-no13    auto
                                           line  17     col 63.
                 04 ss-mp-fld-53 pic x(01) using ws-pay-tp14    auto
                                           line  18     col 35.
                 04 ss-mp-edt-53 pic x(10) from  edt-pay-tp14
                                           background-color 01
                                           foreground-color 06
                                           line  18     col 37.
                 04 ss-mp-fld-54 pic zzzz,zzz.zz
                                           using ws-pay-amt14   auto
                                           line  18     col 48.
                 04 ss-mp-fld-55 pic x(16) using ws-chk-no14    auto
                                           line  18     col 63.

           02 ss-mp-ok           pic x(01) using kb-ok          auto
                                           line  22     col 45.
/
       01  ss-mp-chng-rvrs                 highlight.
           02                    pic x(13) from  ws-chng-or-due-titl
                                           line  19     col 65
                                           background-color 03
                                           foreground-color 06.
           02                    pic zzzzzz,zz9.99
                                           from  ws-change
                                           line  20     col 65
                                           background-color 05
                                           foreground-color 03.

       01  ss-chng-rvrs                    highlight.
           02                    pic x(13) from  ws-chng-or-due-titl
                                           line  19     col 65
                                           background-color 03
                                           foreground-color 06.
           02                    pic zzzzzz,zz9.99
                                           from  ws-change
                                           line  20     col 65
                                           background-color 05
                                           foreground-color 03.

       01  ss-fld-4-fml                    highlight.
           02                    pic x(25) from  ws-fml1-dir
                                           line  06      col 45.
           02                    pic x(75) using ws-nam1
                                           line  07      col 04.

       01  ss-fld-6-fml                    highlight.
           02                    pic x(25) from  ws-fml2-dir
                                           line  08      col 45.
           02                    pic x(75) using ws-nam2
                                           line  09      col 04.
/
       01  ss-multi-pay-titles             highlight
                                           background-color 01
                                           foreground-color 02.
           02 "Document No.  "             line  05     col 02.
           02 " Type ".
           02 "    Amt Due".

       01  ss-cler-mult-data.
           02 "                               "
                                           line  06     col 02.
           02 "                               "
                                           line  07     col 02.
           02 "                               "
                                           line  08     col 02.
           02 "                               "
                                           line  09     col 02.
           02 "                               "
                                           line  10     col 02.
           02 "                               "
                                           line  11     col 02.
           02 "                               "
                                           line  12     col 02.
           02 "                               "
                                           line  13     col 02.
           02 "                               "
                                           line  14     col 02.
           02 "                               "
                                           line  15     col 02.
           02 "                               "
                                           line  16     col 02.
           02 "                               "
                                           line  17     col 02.
           02 "                               "
                                           line  18     col 02.
           02 "                                                 "
                                           line  19     col 02.
           02 "                                                 "
                                           line  20     col 02.

       01  ss-multi-data.
           02 ss-m-fld-1         pic z(14) from  mt-doc-no
                                           line  ln-no  col 02.
           02 ss-m-fld-2         pic x(05) from  mt-doc-tp
                                           line  ln-no  col 17.
           02 ss-m-fld-3         pic zzzzzzz9.99
                                           from  mt-amt-due
                                           line  ln-no  col 22.

       01  ss-multi-amt-due                highlight.
           02                              background-color 01
                                           foreground-color 07.
             03 "Total Due:"               line  ln-no  col 05.
             03                  pic zzzz  from  ws-mult-doc-cnt
                                           line  ln-no  col 17.
             03                  pic zzzzzzzz.zz
                                           from  ws-mult-amt-due
                                           line  ln-no  col 22.
/
       01  ss-multi-revu                   highlight.
           02   "F7 Payoff F10 Save ESCape"
                                           background-color 07
                                           foreground-color 00
                                           line  22     col 05.
           02                              background-color 07
                                           foreground-color 00.
             03                 pic  x(01) from  chr-179
                                           line  22     col 14.
             03                 pic  x(01) from  chr-179
                                           line  22     col 23.
           02                              highlight
                                           background-color 07
                                           foreground-color 06.
             03 "F7"                       line  22     col 05.
             03 "F10"                      line  22     col 15.
             03 "ESC"                      line  22     col 24.

       01  ss-revu                         highlight.
           02   "          "               line  22     col 05
                                           background-color 01.
           02   "F8 Void F9 Reenter F10 Save"
                                           background-color 07
                                           foreground-color 00
                                           line  22     col 15.
           02                              background-color 07
                                           foreground-color 00.
             03                 pic  x(01) from  chr-179
                                           line  22     col 22.
             03                 pic  x(01) from  chr-179
                                           line  22     col 33.
           02                              highlight
                                           background-color 07
                                           foreground-color 06.
             03 "F8"                       line  22     col 15.
             03 "F9"                       line  22     col 23.
             03 "F10"                      line  22     col 34.

       01  ss-revu-f07                     highlight.
           02                              background-color 07
                                           foreground-color 00.

             03 "F7 Payoff"                line  22     col 05.
           02                              background-color 07
                                           foreground-color 00.
             03                 pic  x(01) from  chr-179
                                           line  22     col 14.
           02                              background-color 07
                                           foreground-color 06.
             03 "F7"                       line  22     col 05.

       01  ss-revu-f06                     highlight.
           02                              background-color 07
                                           foreground-color 00.
             03 "F6 Toggle Penalty"        line  23     col 05.
             03 " ESC Cancel".
           02                              background-color 07
                                           foreground-color 06.
             03 "F6"                       line  23     col 05.
             03 "ESC"                      line  23     col 23.
           02                              background-color 07
                                           foreground-color 00.
             03                 pic  x(01) from  chr-179
                                           line  23     col 22.
/
       01  ss-vld-entr                     highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Valid entries are  S  or  M  -"
                                           line  23     col 03.
             03 "  press any key to continue ".
             03                pic x(01)   using nul-entry auto  secure.

       01  ss-missing-doc-no               highlight.
           02                              background-color 07
                                           foreground-color 04.
             03 "Next document number missing from code file"
                                           line  22     col 03.
             03 "Call software support!"   line  23     col 03.
             03                pic x(01)   using nul-entry auto  secure.
             03 "            ".

       01  ss-doc-no-wrong                 highlight.
           02                              background-color 07
                                           foreground-color 04.
             03 "Document No out of sequence - please reset "
                                           line  22     col 03.
             03 "Call software support!"   line  23     col 03.
             03                pic x(01)   using nul-entry auto  secure.
             03 "            ".

       01  ss-missing-rcpt-no              highlight.
           02                              background-color 07
                                           foreground-color 04.
             03 "Next receipt number missing from code file"
                                           line  22     col 03.
             03 "Call software support!"   line  23     col 03.
             03                pic x(01)   using nul-entry  auto  secure.

       01  ss-fee-not-on-file              highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 " Fee record not on file - please rekey number "
                                           line  23     col 03.
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-doc-no-synch                 highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 " Document No out of synch - call supervisor "
                                           line  23     col 03.
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-must-have-page               highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Entry must have number of pages  - "
                                           line  23     col 05.
             03 "press any key ".
             03                 pic 9(02)  from  fld-no.
             03 " ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-not-in-code-file             highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Invalid Code!  "         line  23     col 05.
             03                 pic x(01)  from  prog-lctn.
             03 "  Please check code list. Press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-chng-ovr-50                  highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Warning!  -  change is over $50.00  -  "
                                           line  23     col 05.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-not-enough-money             highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Warning!  -  Not enough money received "
                                           line  23     col 05.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.
/
       01  ss-ovr-30-pgs                   highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Warning - recording is over 30 pages  - "
                                           line  23     col 03.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-begin-bk                     highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Beginning new book  - "
                                           line  23     col 03.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-no-valuation                 highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Warning!  No valuation entered   -  "
                                           line  23     col 03.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-cannot-cancel                highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Cannot cancel until documents are paid off - "
                                           line  23     col 03.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-cannot-change                highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Cannot change record that has already been booked - "
                                           line  23     col 03.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto  secure.
/
       01  ss-kenton-vld-pay-tp            highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 "0-check 1-cash 2-credit 3-a/r 4-exempt"
                                           line  23     col 05.

       01  ss-vld-pay-tp                   highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 "0-check 1-cash 2-credit 3-a/r 4-exempt"
                                           line  23     col 05.

       01  ss-bk-in-use                    highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 "Book "                    line  23     col 03.
             03                 pic  9(02) from  fr-bk-to-rcd-in.
             03 " ".
             03                 pic  x(01) from  fr-rcd-ch.
             03 " in use at connection ".
             03                 pic  9(02) from  ic-locked-by.
             03 "  -  please wait   ".
             03                 pic  x(01) using nul-entry  auto  secure.

       01  ss-need-more                    highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 " Not enough money has been received    "
                                           line  23     col 03.
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-no-change                    highlight.
           02                              background-color 04
                                           foreground-color 07.
             03 " Cannot give change on a credit card  "
                                           line  23     col 03.
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-multi-lft-ovr                highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Warning - there are documents not paid off !"
                                           line  23     col 05.
             03                 pic x(01)  using nul-entry  auto  secure.
/
       01  ss-no-mult-entrd                highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " No documents entered yet for multiple payoff - "
                                           line  23     col 03.
             03 "  press any key  ".
             03                 pic x(01)  using nul-entry  auto secure.

       01  ss-end-multi                    highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " End of Multiple Document  -  "
                                           line  23     col 03.
             03 "  press any key".
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-vldt-chck                    highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Insert Check to validate - press any key "
                                           line  23     col 05.
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-another-rcpt                 highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Do you want another receipt ?   "
                                           line  23     col 05.
             03 "    press Y to print again  ".
             03                 pic x(01)  using kb-receipt auto  secure.

       01  ss-lasr-rcpt                    highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Do you want a receipt ?   "
                                           line  23     col 05.
             03 "    press Y ".
             03                 pic x(01)  using kybd-lasr-rcpt auto  secure.
             
       01  ss-vldt-doc                     highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Insert document to validate - press any key    "
                                           line  23     col 05.
             03                 pic x(01)  using nul-entry  auto  secure.

       01  ss-vl-another-check             highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 "Do you want to validate another check?"
                                           line  23     col 05.
             03 "- press Y to print again".
             03                 pic x(01)  using kb-vl-chks auto  secure.
             
       01  ss-vldt-another                 highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Validate another document ?  -  "
                                           line  23     col 05.
             03 "  press Y to validate again ".
             03                 pic x(01)  using kb-validate auto.

       01  ss-warn-period                  highlight.
           02                              background-color 03
                                           foreground-color 06.
             03 " Warning - please do not use punctuation in names"
                                           line  23     col 05.
             03                 pic x(01)  using nul-entry auto.
/
       01  scrn-load-lock-fail.
           02                              highlight
                                           background-color 04
                                           foreground-color 07.
              03 "Book/page load failure!  Call Eddie or Sevie."
                                           line  23     col 03.
              03 "  ".
              03                pic  x(04) from  ic-cd-tp.
              03 "  ".
              03                pic  x(10) from  ic-id.
              03 "  ".
              03 scrn-load-lock-okay
                                pic  x(01) using find-flag.
                                                                         
       01  scrn-code-fail.
           02                              highlight
                                           background-color 04
                                           foreground-color 07.
              03 "Fee code load fail!  Call support!"
                                           line  23     col 03.
              03 scrn-code-okay pic  x(01) using nul-entry.
              
       01  scrn-xcel-open-eror.
           02                             highlight
                                          background-color 03
                                          foreground-color 06.
              03 "Please close the Void Document Form."
       				    line  24     col 08.      
              03 scrn-xcel-open-eror-okay  
       				    using null-ntry.
                                                   

       01  scrn-xcel-eror-eras.
           02                             highlight
                                          background-color 01
                                          foreground-color 07.
              03 "                                    "     
       			                  line  24     col 08.
              03 "    ".       				           				    
           
       01  ss-erase-err                    highlight.
           02                              background-color 01
                                           foreground-color 07.
              03 "                                                 "
                                           line  23     col 03.
              03 "               ".

       01  ss-fil-bsy                      highlight.
           02                              background-color 07
                                           foreground-color 04.
             03                 pic x(14)  from  file-name(file-nmbr)
                                           line  22     col 03.
             03 " busy at other workstation. ".
             03                 pic x(01)  using nul-entry.

       01  ss-ers-bsy                      highlight.
           02                              background-color 01
                                           foreground-color 07.
             03 "                      "   line  22     col 03.
             03 "                              ".

       01  ss-fil-err                      lowlight.
           02                              background-color 07
                                           foreground-color 04.
             03                 pic x(14)  from  file-name(file-nmbr)
                                           line  22     col 03.
             03 " status = ".
             03                 pic x(02)  from  file-stts.
             03 " ".
             03                 pic 9(01)  from  file-sts1.
             03 ".".
             03                 pic 9(03)  from  file-sts2.
             03 " ".
             03 "Call support!"            line  23     col 03.
             03 ss-fil-rply     pic x(01)  using nul-entry.
/
       procedure division using user-name
                                user-levl
                                sttn-nmbr
                                prtr-name                       
                                swch-nmbr.
                                                           
       declaratives.

       file-eror section.
           use after standard error procedure on fee-file
                                                 fee-rcpt
                                                 ixcd-file
                                                 multi-tmp
                                                 fees-jrnl
                                                 indx-code
                                                 notr-file
                                                 fil-xrf.
       file-eror-proc.
           if       file-stts                 =     lock-stts
                    display  ss-fil-bsy
                    accept   ss-fil-bsy
                    display  ss-ers-bsy
           else
                    display  ss-fil-err            
                    accept   ss-fil-rply 
                    exit     program.
           end      declaratives.
/
           perform  init-prog.
           perform  entr-clk-ch.
           perform  slct-mode
                    until    run-mode         =     "E".
           perform  clos-fils.       
           exit     program.
           
       slct-mode.
           perform  init-store.                                 
           display  ss-dflt
           perform  dsply-brdr
           perform  dsply-hedr
           display  ss-fee-titls.
           perform  entr-sngl-mult.
           perform  entr-doc-no
                    until   run-mode          >     space.
                    
           if       run-mode                  not = "E"
                    perform main-proc.

       main-proc.
           display  ss-fee-data.
           if       run-mode                  =     "A"
                    perform  entr-fld
                             until  fld-no    >     25
           else
                    move     fr-valuation     to    ws-valuation
                    perform  vldt-fld
                             varying fld-no   from  01
                                              by    01
                             until   fld-no   >     12
                    display  ss-fee-data.

           display  ss-revu.
           perform  revu-fld
                    until    kb-ok            =     "Y"
                    or       kb-ok            =     "V"
                    or       kb-ok            =     "C".

           if       kb-ok                     not = "C"
                    perform  otpt-proc.
           display  ss-fee-titls.                                        
/
       revu-fld.
           move     space                       to    kb-ok.
           display  ss-ok.
           if       kb-sngl-mult                not = "M"
                    display  ss-revu-f07.
           display  ss-revu-f06.

           accept   ss-ok.

*          if       crt-s2                      =     09            *> Added to kill effects of F9 key.
*          and      run-mode                    =     "C"           *>
*                   move     99                 to    crt-s2        *>
*                   move     space              to    kb-ok.        *> Removed 10/16/07 EPA.

           if       crt-s2                      =     zero
           and      run-mode                    not = "A"
                    move     "C"                to    kb-ok.

           if       crt-s2                      =     10
           and      fr-amt-recd                 <     fr-amt-due
           and      kb-sngl-mult                =     "S"
           and      ws-pay-tp1                  not = "3"
                    display  ss-not-enough-money                         
                    accept   ss-need-more                             
                    display  ss-erase-err
                    move     07                 to    crt-s2
                    move     space              to    kb-ok.

           if       crt-s2                      =     10
           and      run-mode                    =     "A"
                    move     "Y"                to    kb-ok.
                                                                      
           if       crt-s2                      =     10
           and      run-mode                    =     "C"
                    move     "Y"                to    kb-ok.

           if       crt-s2                      =     09            *> F9 key in action. F9 = "N" kb-ok.
           and      fr-amt-recd                 =     zero          *> No dollars involved.
                    move     "N"                to    kb-ok         *>
           else                                                     *> why the else?
           if       crt-s2                      =     09            *>
*          and      run-mode                    =     "A"           *> Add mode, don't care about
                    move     "N"                to    kb-ok.        *> dollars.  Go farther down.
                    
           if       crt-s1			=     01	    *> F8 key
           and      crt-s2                      =     08            *> void a record in change mode
           and      run-mode                    =     "C"
                    move     "V"                to    kb-ok.
                                   

           if       crt-s2                      =     06
           and      fr-pnly-fee                 >     zero
                    move     zero               to    fr-pnly-fee
                    perform  calc-amt-due
                    display  ss-fee-data
           else
           if       crt-s2                      =     06
           and      fr-pnly-fee                 =     zero
                    move     2.00               to    fr-pnly-fee
                    perform  calc-amt-due
                    display  ss-fee-data.
/
           if       kb-ok                       =     "N"           *> Here we go. F9 causes this.
           and      run-mode                    =     "A"           *> Add mode.
                    move     01                 to    fld-no        *> Complete re entry.
                    perform  unlock-own-bk-pg                       *>
                    perform  entr-fld                               *>
                             until    fld-no    >     25.           *> To field 26.

           if       kb-ok                       =     "N"           *>
           and      run-mode                    not = "A"           *> Change mode.
           and      fr-receipt-no               =     ws-receipt-no *> How does this play?
                    move     02                 to    fld-no        *>
                    perform  entr-fld                               *>
                             until    fld-no    >     13            *> Up to field 14 only.
                    perform  calc-amt-due                           *>
                    display  ss-rcd-fees                            *>
           else                                                     *>
           if       kb-ok                       =     "N"           *> This look like what's needed.
           and      run-mode                    not = "A"           *> Change mode.
                    move     02                 to    fld-no        *>
                    perform  entr-fld                               *>
                             until    fld-no    >     06.           *> Up to field 7 only.

           if       crt-s2                      =     07
           and      kb-sngl-mult                not = "M"
           and      fr-amt-recd                 not > zero
                    perform  payout-prc
           else
           if       crt-s2                      =     07
           and      kb-sngl-mult                not = "M"
           and      run-mode                    =     "A"
                    perform  payout-prc.

           if       crt-s2                      =     zero          *> void a record in add mode
           and      run-mode                    =     "A"
                    display  "voiding record"   at    2301
                    move     "V"                to    kb-ok.
/
       otpt-proc.
           if       kb-ok                       =     "V"
           and      fr-amt-recd                 >     zero
           and      run-mode                    =     "C"
           and      fr-receipt-no               >     space
                    perform  otpt-void-rcpt-records.

           if       kb-ok                       =     "V"           
                    perform  unlock-own-bk-pg                    
                    perform  otpt-void-rcrd.

           if       kb-sngl-mult                =     "M"
           and      kb-ok                       =     "Y"
           and      fr-amt-due                  >     zero
                    move     fr-doc-no          to    mt-doc-no
                    move     fr-doc-tp          to    mt-doc-tp
                    move     fr-amt-due         to    mt-amt-due
                    add      fr-amt-due         to    ws-mult-amt-due
                    move     03                 to    file-nmbr
                    write    multi-tmp-record
                             invalid  key
                                      rewrite multi-tmp-record.
/
           if       kb-ok                       =     "Y"
           and      kb-sngl-mult                not = "M"                    
                    perform  otpt-fee-rcpt.
                                                       
           move     ws-pay-tp1                  to     fr-pay-tp1.   *> added 07/13/12 in an attempt to get
           move     ws-pay-tp2                  to     fr-pay-tp2.   *> the pay type to print in 'feep'.
           move     ws-pay-tp3                  to     fr-pay-tp3.
           move     ws-pay-tp4                  to     fr-pay-tp4.

           move     ws-pay-amt1                 to     fr-pay-amt1.  *> added 07/27/12 in an attemtp to get
           move     ws-pay-amt2                 to     fr-pay-amt2.  *> the pay type to print in 'feep'.
           move     ws-pay-amt3                 to     fr-pay-amt3.
           move     ws-pay-amt4                 to     fr-pay-amt4.

           move     ws-chk-no1                  to     fr-chk-no1.   *> added 07/13/12 in an attempt to get
           move     ws-chk-no2                  to     fr-chk-no2.   *> the check number to print in 'feep'.
           move     ws-chk-no3                  to     fr-chk-no3.
           move     ws-chk-no4                  to     fr-chk-no4.
                                     
           if       run-mode                    =      "A"
           and      ws-pay-tp1                  =      "3"     *> A/R pay type
                    move     zero               to     fr-amt-recd
                    move     ws-receipt-no      to     fr-receipt-no            
                    perform  write-fee-record
           else
           if       run-mode                    =      "A"
                    move     fr-amt-due         to     fr-amt-recd
                    move     ws-chk-no1         to     fr-chk-no1 *> 07/21/11 epa, check number
                    move     ws-receipt-no      to     fr-receipt-no
                    perform  write-fee-record
           else
           if       run-mode                    =      "C"
           and      ws-pay-tp1                  =      "3"
                    move     zero               to     fr-amt-recd
                    move     ws-receipt-no      to     fr-receipt-no               
                    perform  rewrite-fee-record
           else
           if       run-mode                    =      "C"
                    move     fr-amt-due         to     fr-amt-recd
*                   move     ws-receipt-no      to     fr-receipt-no
                    perform  rewrite-fee-record.

           if       kb-ok                       =      "Y"                   
           and      run-mode                    =      "A"
*          and      swch-nmbr(01)               =      "+"
*          and                                         kenton
           and      fr-doc-cls                  not =  20
                    perform  updt-bk-pg.

           if       kb-ok                       =      "Y"
           and      run-mode                    =      "A"
*          and                                         kenton
*          and      swch-nmbr(01)               =      "+"
           and      fr-doc-cls                  =      20
           and      fr-doc-tp                   =      "MVLS"
                    perform  updt-bk-pg.

           if       kb-ok                       =      "Y"
           and      run-mode                    =      "A"
*          and                                         kenton
*          and      swch-nmbr(01)               =      "+"
           and      fr-doc-cls                  =      20
           and      fr-doc-tp                   =      "MHLS"
                    perform  updt-bk-pg.

           if       kb-ok                       =      "Y"
           and      run-mode                    =      "A"
*          and                                         kenton         
*          and      swch-nmbr(01)               =      "+"
           and      fr-doc-cls                  =      20
           and      fr-doc-tp                   =      "UCC1"
                    perform  updt-bk-pg.

           if       kb-ok                       =      "Y"
           and      run-mode                    =      "A"
*          and                                         kenton
*          and      swch-nmbr(01)               =      "+"
           and      fr-doc-cls                  =      20
           and      fr-doc-tp                   =      "UCC-SE"
                    perform  updt-bk-pg.

           if       kb-ok                       =      "Y"
                    perform  proc-rcpt.
                                                
           perform  otpt-fees-jrnl.

           if       kb-ok                       =      "Y"
           and      fr-doc-tp                   =      "NP"
                    perform  otpt-ntry.
/
       otpt-void-rcrd.
           move     fr-name2		        to    save-nam2.
           display  save-nam2			at    0201.
           if       run-mode                    =     "C"
                    move     "VOID - VOID - VOID - VOID"
                                                to    fr-name2
           else
                    move     "( cancelled )"    to    fr-name2.
           move     zero                        to    fr-trnsf-tax.
           move     zero                        to    fr-valuation.
           move     zero                        to    fr-rcd-fee.
           move     fr-amt-due			to    save-amnt-due.
           move     zero                        to    fr-amt-due.
           move     zero                        to    fr-pnly-fee.
           move     zero                        to    fr-addl-fee.
           move     zero                        to    fr-addl-pg-fee.
           move     zero                        to    fr-clrk-cmsn.
           move     zero                        to    fr-afrd-hous.
           move     zero                        to    fr-stat-fees.
           move     zero                        to    fr-clrk-fees.
           move     zero                        to    fr-pstg-fee.
           move     zero                        to    fr-amt-recd.
           move     zero                        to    ws-change.
           move     zero                        to    ws-pay-amt1.
           move     zero                        to    ws-pay-amt2.
           move     zero                        to    ws-pay-amt3.
           move     zero                        to    ws-pay-amt4.
           move     zero                        to    ws-pay-amt5.
           move     zero                        to    ws-pay-amt6.
           move     zero                        to    ws-pay-amt7.
           move     zero                        to    ws-pay-amt8.
           move     zero                        to    ws-pay-amt9.
           move     zero                        to    ws-pay-amt10.
           move     zero                        to    ws-pay-amt11.
           move     zero                        to    ws-pay-amt12.
           move     zero                        to    ws-pay-amt13.
           move     zero                        to    ws-pay-amt14.
           move     "VOIDED"                    to    fr-bkkp-cd.
           if       run-mode                    =     "A"
                    move     zero               to    fr-beg-bk
                                                      fr-beg-pg
                                                      fr-end-bk
                                                      fr-end-pg.
           perform  void-mult-tmp.
           
           if       fr-beg-bk                   >     zero
                    perform  otpt-void-deed-list
                    perform  otpt-void-dcmt-xref
                    perform  otpt-void-xcel.
           if	    fr-doc-tp			=     "MVLS"
           and      fr-file-no			not = zero
                    perform  otpt-void-file-xref
                    perform  otpt-void-xcel.  
                                                    
       otpt-void-deed-list.
           initialize deed-list-rcrd.
           move     fr-rcd-ch                   to     deed-cort-hous.
           move     fr-beg-bk                   to     deed-book.
           move     fr-beg-pg                   to     deed-page.
           move     fr-doc-no                   to     deed-dcmt.
           move     zero                        to     deed-dcmt-clas.
           move     "VOID-VOID"                 to     deed-dcmt-type.
           move     zero                        to     deed-book-clas.
           move     file-nmbr-deed-list         to     file-nmbr.
           write    deed-list-rcrd.

       otpt-void-dcmt-xref.
           initialize dcmt-xref-rcrd.
           move     fr-rcd-ch                   to     dcmt-xref-lctn.
           move     fr-doc-no                   to     dcmt-xref-nmbr.
           move     "VOID-VOID"                 to     dcmt-xref-type.
           move     space                       to     dcmt-xref-clas.
           move     space                       to     dcmt-xref-book-clas.
           move     fr-beg-bk                   to     dcmt-xref-book.
           move     fr-beg-pg                   to     dcmt-xref-page.
           move     file-nmbr-dcmt-xref         to     file-nmbr.
           write    dcmt-xref-rcrd.                                              
/           
       otpt-void-file-xref.       
           initialize flxrf-rec.
           move     file-nmbr-fil-xrf		to	file-nmbr.
           open     i-o  fil-xrf.  
           move     fr-file-no			to	flx-file-no.
           move     fr-doc-no			to	flx-doc-no.
           move     fr-doc-cls			to	flx-doc-cls.
           move     fr-doc-tp			to	flx-doc-tp.
           move     "VOID-VOID-VOID"		to	flx-vin.
           write    flxrf-rec.
	   close    fil-xrf.           

       otpt-void-xcel.      
           perform  dele-xcel.                              *> delete previous copy
           move     space			to	term-chck.
           move     zero			to	wait-maxm-cntr.
           perform  chck-file
           	    until      term-chck	not =         space.
           if	      term-chck			=	        "o"                                          
           	      display   scrn-xcel-open-eror
           	      accept    scrn-xcel-open-eror-okay  
           	      display   scrn-xcel-eror-eras
           else
           	      perform   otpt-void-xcel-proc.
     	                                                          
        otpt-void-xcel-proc.                                            
           perform  inpt-xcel.
           if       fr-doc-tp		 	  =           "MVLS"
           	    perform  otpt-void-mvls-xcel
           else
           	    perform  otpt-void-land-xcel.
           perform  save-xcel.
           perform  fnlz-xcel.            
                                             
        otpt-void-mvls-xcel.  
           move     02				  to	      rows-cntr.
           move     02				  to	      clmn-cntr.
           string   "-- V O I D -- M V L S -- V O I D -- M V L S --"
           					  delimited by size
                    x'00'			  delimited by size           					  
           					  into	      cell-valu.
           perform  otpt-cell.
                                
           move     04				  to	      rows-cntr.
           move     02				  to	      clmn-cntr.
           move     fr-file-no			  to	      edit-file-nmbr.
           string   "This File# "                 delimited by size
                    edit-file-nmbr		  delimited by size
                    " and Doc# "		  delimited by size
                    fr-doc-no			  delimited by size
                    " is void:"		          delimited by size
                    x'00'			  delimited by size
                    				  into	      cell-valu.
           perform  otpt-cell.
           
           *>-----  creditor         
           move     08				  to	      rows-cntr.
           move     02				  to	      clmn-cntr.
                                           
           if	    fr-name-tp1			  =           "B"                           
                    string "Party1: "	          delimited by size
                           fr-frst-name1	  delimited by "  "
                           " "			  delimited by size
                           fr-midl-name1	  delimited by "  "
                           " "			  delimited by size
                           fr-last-name1	  delimited by "  "
                           x'00'		  delimited by size
                           			  into	      cell-valu
           else
           	    string "Party1: "             delimited by size
           	           fr-last-name1          delimited by "  "
                           " "			  delimited by size
                           fr-frst-name1	  delimited by "  "
                           " "			  delimited by size
                           fr-midl-name1	  delimited by "  "
                           x'00'		  delimited by size
                          
	   					  into         cell-valu.                           			
           perform  otpt-cell.
                                      
           *>-----  debtor            
           move     10				  to	      rows-cntr.
           move     02				  to	      clmn-cntr.
                                       
           if	    fr-name-tp2			  =           "B"
                    string "Party2: "	          delimited by size
                           save-nam2-frst	  delimited by "  "
                           " "			  delimited by size
                           save-nam2-midl	  delimited by "  "
                           " "			  delimited by size
                           save-nam2-last	  delimited by size
                           x'00'	          delimited by size
                           			  into	      cell-valu
           else
           	    string "Party2: "             delimited by size
           	           save-nam2-last         delimited by "  "
                           " "			  delimited by size
                           save-nam2-frst	  delimited by "  "
                           " "			  delimited by size
                           save-nam2-midl	  delimited by "  "
                           x'00'		  delimited by size
	   					  into         cell-valu.                           			
           perform  otpt-cell.     
                       
           *>-----  delete "Number of Pages" wording
           
           move     27				  to	       rows-cntr.
           move     02				  to	       clmn-cntr.
           perform  otpt-cell.
                                       
           move     04				  to	       clmn-cntr.
           perform  otpt-cell.
           
           *>------  amount due ------------------
           move     28				  to	      rows-cntr.
           move     04				  to	      clmn-cntr.
           move     save-amnt-due                 to	      edit-amnt.
           string   edit-amnt			  delimited by size
                    x'00'			  delimited by size
                    				  into        cell-valu.
           perform  otpt-cell.

           *>------  clerk name
           move     36				  to	       rows-cntr.
           move     03				  to           clmn-cntr.
           string   edt-clrk-name		  delimited by "  "
                    x'00'			  delimited by size
                    				  into 	       cell-valu.
           perform  otpt-cell.      
        
        otpt-void-land-xcel.  
           move     02				  to	      rows-cntr.
           move     02				  to	      clmn-cntr.
           string   "-- V O I D -- V O I D -- V O I D -- V O I D --"
           					  delimited by size
                    x'00'			  delimited by size           					  
           					  into	      cell-valu.
           perform  otpt-cell.
           
           move     04				  to	      rows-cntr.
           move     02				  to	      clmn-cntr.
           move     fr-file-no			  to	      edit-file-nmbr.
           string   "These page(s) from Document#" 
           					  delimited by size
                    " "				  delimited by size
                    fr-doc-no			  delimited by size
                    " are void:"		  delimited by size
                    x'00'			  delimited by size
                    				  into	      cell-valu.
           perform  otpt-cell.
  
           move     fr-beg-pg			  to	      void-page-cntr.
           move     01				  to	      void-item-cntr.
           move     06				  to	      rows-cntr.
           perform  otpt-void-land-incr
                    until	void-page-cntr	  >           fr-end-pg.
                    
           *>------  amount due ------------------
           move     28				  to	      rows-cntr.
           move     04				  to	      clmn-cntr.
           move     save-amnt-due                 to	      edit-amnt.
           string   edit-amnt			  delimited by size
                    x'00'			  delimited by size
                    				  into        cell-valu.
           perform  otpt-cell.
                    
           *>------  clerk name
           move     36				  to	       rows-cntr.
           move     03				  to           clmn-cntr.
           string   edt-clrk-name		  delimited by "  "
                    x'00'			  delimited by size
                    				  into 	       cell-valu.
           perform  otpt-cell.                          
           
        otpt-void-land-incr.   *> creates four rows of 20 items each column
           if       void-item-cntr		  <           21
                    move    02			  to	      clmn-cntr
           else
           if	    void-item-cntr		  >=	      21
           and      void-item-cntr		  <=          40
                    move    04			  to	      clmn-cntr
           else
           if	    void-item-cntr		  >=          41
           and      void-item-cntr		  <=          60
                    move    06			  to	      clmn-cntr
           else
           if	    void-item-cntr		  >           60
                    move    08			  to	      clmn-cntr.
           move     fr-beg-bk			  to	      edit-begn-book.
           move     void-page-cntr		  to	      edit-void-page-cntr.
           string   fr-rcd-ch			  delimited by size
                    edit-begn-book		  delimited by size
                    "/"				  delimited by size
                    edit-void-page-cntr 	  delimited by size
                    x'00'			  delimited by size
                    				  into	      cell-valu.
          perform   otpt-cell.  
          add       01			          to	      void-page-cntr.
          add       01				  to	      void-item-cntr.
          add       01				  to	      rows-cntr.
          if        void-item-cntr		  =           21           
          or        void-item-cntr		  =	      41
          or        void-item-cntr		  =           61
                    move     06		          to	      rows-cntr.
           
        chck-file.           
           perform  dele-xcel.      
           call     "cbl_check_file_exist"        using       xcel-path
                                        	              file-detl
                                        	  returning   stts-code.     
           if	    stts-code			  =           zero
           	    add	01		          to	      wait-maxm-cntr
           	    perform  proc-wait
           else                        
           	    move     "x"		  to	      term-chck.      
           if	    wait-maxm-cntr		  >	      07
           	    move     "o"		  to	      term-chck.	      
          	      
                                                                         
       dele-xcel.   *> delete prior ML in c:\temp\MarriageLicense.xls
           call     "cbl_delete_file"		  using         xcel-path
    					  returning     stts-code.                             
     	   
       otpt-fees-jrnl.
           move     fr-doc-tp                   to     indx-code-valu.
           move     fr-rcd-ch                   to     indx-cort-hous.
           move     06                          to     file-nmbr.
           read     indx-code
                    ignore   lock
                    invalid  key
                             initialize indx-rcrd.

           move     fr-doc-no-yr                to     fees-jrnl-year.
           move     fr-doc-no-mt                to     fees-jrnl-mnth.
           move     fr-doc-no-dy                to     fees-jrnl-days.
           move     fr-doc-cnty                 to     fees-jrnl-code.
           move     fr-doc-daily-no             to     fees-jrnl-sqnc.

           move     lock-stts                   to     file-stts.
           perform  otpt-fees-jrnl-read
                    until    file-stts          not =  lock-stts.

           move     fr-doc-date                 to     fees-jrnl-date.
           move     fr-doc-time                 to     fees-jrnl-time.

           move     fr-doc-tp                   to     fees-jrnl-dcmt-code.
           move     fr-doc-cls                  to     fees-jrnl-dcmt-clas.

           move     fr-bkkp-cd-no               to     fees-jrnl-acnt-nmbr.
           move     fr-bkkp-cd-tp               to     fees-jrnl-acnt-clas.

           move     fr-rcd-fee                  to     fees-jrnl-rcrd-fees.
           move     indx-stat-fees              to     fees-jrnl-stat.
           move     indx-clrk-fees              to     fees-jrnl-clrk.
           multiply indx-stat-fees              by     indx-cmsn-rate
                                                giving fees-jrnl-clrk-cmsn rounded.
           move     indx-afrd-hous              to     fees-jrnl-afrd-hous.
           move     indx-cnty-fees              to     fees-jrnl-cnty.
           move     fr-trnsf-tax                to     fees-jrnl-xfer-taxs.
           move     fr-pnly-fee                 to     fees-jrnl-plty-amnt.
           move     fr-pstg-fee                 to     fees-jrnl-clrk-pstg.
           move     indx-vitl-pstg              to     fees-jrnl-vitl-pstg.
           move     fr-no-pages                 to     fees-jrnl-page-cntr.
           move     fr-addl-pg-fee              to     fees-jrnl-adtl-page.
           move     fr-addl-fee                 to     fees-jrnl-adtl-fees.
           move     zero                        to     fees-jrnl-misc.
           move     fr-amt-due                  to     fees-jrnl-totl-amnt.
           move     indx-lbry-arch              to     fees-jrnl-lbry-arch.
           move     zero                        to     fees-jrnl-usag.
           move     fr-amt-recd                 to     fees-jrnl-amnt-rcvd.
           move     01                          to     fees-jrnl-dcmt-cntr.
           move     fr-rcd-ch                   to     fees-jrnl-rcrd-cort.
           move     fr-clctn-ch                 to     fees-jrnl-lctn-cort.
           move     fr-clk-id                   to     fees-jrnl-user.
           move     fr-pay-tp1                  to     fees-jrnl-pymt-type.
           move     zero                        to     fees-jrnl-card-nmbr.
           move     space                       to     fees-jrnl-filr.

           if       file-sts1                   =      zero
                    rewrite  fees-jrnl-rcrd
           else
                    write    fees-jrnl-rcrd.

       otpt-fees-jrnl-read.
           move     09                          to     file-nmbr.
           read     fees-jrnl
                    invalid  key
                             move     "23"      to     file-stts.

       otpt-ntry.
           move     fr-doc-no                   to     notr-dcmt.
           move     fr-rcd-ch                   to     notr-lctn.
           move     fr-beg-bk                   to     notr-book.
           move     fr-beg-pg                   to     notr-page.
           move     fr-beg-sx                   to     notr-sufx.
           move     07                          to     file-nmbr.
           write    notr-rcrd
                    invalid  key
                             move     "23"      to     file-stts.
                             
/
       init-prog.
           move     "+"                         to     swch-nmbr(01).
           move     01                          to     file-nmbr.
           display  ss-dflt.
           inspect  dh-ln
                    replacing characters        by     chr-205.
           inspect  sh-ln
                    replacing characters        by     chr-196.
           move     zero                        to     rec-cnt.

           move     01                          to     file-nmbr.
           open     i-o      fee-file.
           move     02                          to     file-nmbr.
           open     i-o      ixcd-file.
           move     04                          to     file-nmbr.
           open     i-o      fee-rcpt.
           move     05                          to     file-nmbr.
           open     i-o      fees-jrnl.
           move     06                          to     file-nmbr.
           open     input    indx-code.
           move     07                          to     file-nmbr.
           open     i-o      notr-file.
           move     file-nmbr-deed-list         to     file-nmbr.
           open     i-o      deed-list.
           move     file-nmbr-dcmt-xref         to     file-nmbr.
           open     i-o      dcmt-xref.

           move     space                       to     dt-prnt.
           move     space                       to     print-record.
           move     space                       to     kb-sngl-mult.
           move     space                       to     kb-payoff.
           move     space                       to     fee-record.
           call     x"AF"                       using  caps-lock-1
                                                       caps-lock-2.
                    
           if       sttn-nmbr			=      36
           or       sttn-nmbr			=      40
           or       sttn-nmbr		        =      52
                    move     space		to     lasr-rcpt-sttn   *> ithaca receipt print station
           else                    
           	    move     "y"		to     lasr-rcpt-sttn.  *> laser printer print station
           	    
           perform  chck-for-otstnd-mult.
           perform  load-local-official.
           perform  chck-for-dymo-sfwr.

       load-local-official.
           move     0002                        to    ic-cd-tp.
           move     "CLRK"                      to    ic-id.
           move     lock-stts                   to    file-stts.
           perform  read-ixcd-file
                    until    file-stts          not = lock-stts.
           if       file-stts                   =     "00"
                    move     ic-offc-name       to    ws-offc-name
                    move     ic-offcl-name      to    ws-offcl-name
                    move     ic-offcl-title     to    ws-offcl-title
           else
                    move     space              to    ws-offc-name
                    move     space              to    ws-offcl-name
                    move     space              to    ws-offcl-title.
           perform  release-code-record.
/
       chck-for-otstnd-mult.
           move     03                          to     file-nmbr.
           open     i-o      multi-tmp.
           if       file-stts                   not =  "00"
                    open     output  multi-tmp
                    close    multi-tmp
                    open     i-o     multi-tmp.

           read     multi-tmp
                    next
                    at       end
                             move     "10"      to     file-stts.

           if       file-stts                   =      "00"
           and      mt-doc-no                   >      zero
                    move     "M"                to     kb-sngl-mult
                    add      mt-amt-due         to     ws-mult-amt-due
                    display  ss-multi-lft-ovr
                    accept   ss-multi-lft-ovr
                    display  ss-erase-err.

           close    multi-tmp.
           open     i-o      multi-tmp.

       chck-for-dymo-sfwr.
           initialize file-info.
           move     space			to     dymo-flag.
           call     "cbl_check_file_exist"      using  dymo-file-nam1
                                                       file-detl
                                                returning stts-code.
           if       stts-code                   =      zero
                    move  "y"                   to     dymo-flag
           else                    
           	    perform  chck-for-dymo-64bt.
           if	    dymo-flag			=      space
                    move  "com1"		to     prnt-path.
                                                                 
      chck-for-dymo-64bt.           	    
           call     "cbl_check_file_exist"      using  dymo-file-nam2
                                                       file-detl
                                                returning stts-code.
           if       stts-code                   =      zero
                    move  "y"                   to     dymo-flag.

/
       init-store.
           initialize  ws-pay-flds.
           move     zero                        to    ws-receipt-no.
           move     space                       to     run-mode.
           move     space                       to     kb-payoff.
           move     space                       to     kb-ok.
           move     space                       to     ws-chng-or-due-titl.
           move     zero                        to     fr-doc-no.
*          move     zero                        to     ws-rcpt-no.
           move     01                          to     fld-no.
           move     space                       to     edt-rcd-ch.
           move     space                       to     edt-doc-dsc.

           move     space                       to     edt-pay-tp1.
           move     space                       to     edt-pay-tp2.
           move     space                       to     edt-pay-tp3.
           move     space                       to     edt-pay-tp4.
           move     space                       to     edt-pay-tp5.
           move     space                       to     edt-pay-tp6.
           move     space                       to     edt-pay-tp7.
           move     space                       to     edt-pay-tp8.
           move     space                       to     edt-pay-tp9.
           move     space                       to     edt-pay-tp10.
           move     space                       to     edt-pay-tp11.
           move     space                       to     edt-pay-tp12.
           move     space                       to     edt-pay-tp13.
           move     space                       to     edt-pay-tp14.

           move     zero                        to     ws-no-pages.
           move     zero                        to     ws-addl-pg-amt.
           move     zero                        to     ws-afrd-hous.
           move     zero                        to     ws-rcd-fee.
           move     zero                        to     ws-addl-pg-fee.
           move     zero                        to     ws-pstg-fee.
           move     zero                        to     ws-pnly-fee.
           move     zero                        to     ws-addl-fee.
           move     zero                        to     ws-trnsf-tax.
           move     space                       to     ws-trnsf-tax-flg.
           move     space                       to     ws-nam1.
           move     space                       to     ws-nam2.
           move     space                       to     ws-nam.
           move     space                       to     ws-frst.
           move     space                       to     ws-midl.
           move     space                       to     ws-last.
/
       entr-clk-ch.
           move     space                       to     valid-clk-id.
           move     space                       to     valid-ch.
           perform  entr-clk-id
                    until   valid-clk-id        =      "Y"
                    or      run-mode            =      "E".
           perform  entr-clctn-ch
                    until   valid-ch            =      "Y"
                    or      run-mode            =      "E".

           if       valid-ch                    not =  "Y"
           or       valid-clk-id                not =  "Y"
                    move    "E"                 to     run-mode.

       entr-clk-id.
           perform  smpl-tim.
           perform  dsply-brdr.
           perform  dsply-hedr.
           move     space                       to    kb-clk-id.
           move     space                       to    valid-clk-id.
           display  ss-clk-id.
           display  ss-clk-titls.
           accept   ss-clk-id.
           if       crt-s2                      =     zero
                    move     "E"                to    run-mode
           else
                    perform  entr-clrk-vldt.

       entr-clrk-vldt.
           move     0005                        to    ic-cd-tp.
           move     kb-clk-id                   to    ic-id.
           move     lock-stts                   to    file-stts.
           perform  read-ixcd-file
                    until    file-stts          not = lock-stts.
           if       file-stts                   =     "00"
                    move     "Y"                to    valid-clk-id
                    move     ic-clk-name        to    edt-clrk-name
                    display  edt-clrk-name      at    1045
           else
                    move     "C"                to    prog-lctn
                    perform  not-in-code-file
                    move     space              to    prog-lctn.
           perform  release-code-record.

       entr-clctn-ch.
           move     ic-clk-ch                   to    kb-clctn-ch.
           display  ss-clctn-ch.
           accept   ss-clctn-ch.
           display  ss-clctn-ch.

           if       crt-s2                      =     zero
                    move     "E"                to    run-mode
           else
                    perform  cont-entr-clctn-ch.

           perform  release-code-record.
/
       cont-entr-clctn-ch.
           move     0004                        to    ic-cd-tp.
           move     kb-clctn-ch                 to    ic-id.
           move     lock-stts                   to    file-stts.
           perform  read-ixcd-file
                    until    file-stts          not = lock-stts.
           if       file-stts                   =     "00"
                    move     "Y"                to    valid-ch
                    move     ic-ch-lcn          to    edt-clctn-ch
                    move     ic-bank-acct-no    to    edt-clctn-acct-no
                    move     ic-bank-name       to    edt-clctn-bank-name
                    display  ss-clctn-ch
           else
                    move     "L"                to    prog-lctn
                    perform  not-in-code-file
                    move     space              to    prog-lctn.
           perform  release-code-record.
/
       entr-doc-no.
           move     zero                        to    fr-doc-no.      
*          move     zero                        to    ws-rcpt-no.

           if       kb-sngl-mult                =     "M"
                    display  ss-f7.

           display  ss-key.
           accept   ss-key.
           display  ss-key.

           if       crt-s2                      =     zero
           and      kb-sngl-mult                not = "M"
                    perform  entr-doc-no-unlk.

           if       crt-s2                      =     zero
           and      kb-sngl-mult                =     "M"
           and      ws-mult-amt-due             =     zero
                    move     "E"                to    run-mode
           else
           if       crt-s2                      =      zero
           and      kb-sngl-mult                =      "M"
           and      ws-mult-amt-due             >     zero
                    display  ss-cannot-cancel
                    accept   ss-cannot-cancel
                    display  ss-erase-err                                
           else
           if       crt-s2                      =     07
           and      kb-sngl-mult                =     "M"
           and      ws-mult-amt-due             not > zero
                    display  ss-no-mult-entrd
                    accept   ss-no-mult-entrd
                    display  ss-erase-err
           else
           if       crt-s2                      =     07
           and      kb-sngl-mult                =     "M"        
                    perform  mp-mult-payoff
           else
           if       run-mode                    not = "E"
                    perform  inpt-fee-rec.

       entr-doc-no-unlk.   *> unlock
           move     0007                        to    ic-cd-tp.
           move     fr-bk-to-rcd-in             to    ic-id.
           move     fr-rcd-ch                   to    ic-bk-tp-ch-lcn.
           move     lock-stts                   to    file-stts.
           perform  read-ixcd-file
                    until      file-stts        not = lock-stts.

           if       file-sts1                   =     zero
           and      ic-locked                   =     "LOCKED"
           and      ic-locked-by                =     sttn-nmbr
           and      ic-lst-bk-used              =     fr-beg-bk
           and      ic-lst-pg-used              =     fr-beg-pg - 1
                    move     "      "           to    ic-locked
                    move     zero               to    ic-locked-by
                    move     "E"                to    run-mode
                    move     02                 to    file-nmbr
                    rewrite  index-code-record
                             invalid  key
                                      move    "22"
                                                to    file-stts.


       entr-sngl-mult.
           perform  smpl-tim.
           perform  dsply-brdr.
           perform  dsply-hedr.
           perform  cler-fee-rec.
           display  ss-fee-titls.
           display  ss-fee-data.

           if       kb-sngl-mult                not = "M"
                    move     space              to    kb-sngl-mult
                    move     space              to    edt-sngl-mult
                    move     zero               to    ws-mult-amt-due
                    move     zero               to    ws-mult-doc-cnt.

           perform  entr-sngl-mult-cd
                    until    kb-sngl-mult       =     "S"
                    or       kb-sngl-mult       =     "M"                    
                    or       run-mode           =     "E".
                                                                  
       entr-sngl-mult-cd.
           display  ss-sngl-mult.
           display  ss-sm-titl.
           accept   ss-sngl-mult.
           display  ss-sngl-mult.
           if       crt-s2                      =     zero
                    move     "E"                to    run-mode.


           if       kb-sngl-mult                =     space
                    move     "S"                to    kb-sngl-mult.


           if       kb-sngl-mult                =     "S"
                    move     "Single document"  to    edt-sngl-mult
                    display  ss-fee-pay-titls
           else
           if       kb-sngl-mult                =     "M"
                    move     "Multi documents"  to    edt-sngl-mult
           else
                    display  ss-vld-entr
                    accept   ss-vld-entr            
                    display  ss-erase-err. 

           display  ss-sngl-mult.
           display  ss-edt-sngl-mult.
/
       inpt-fee-rec.
           if       fr-doc-no                   =      zero
                    perform  load-next-doc-no
                    perform  load-new-doc
           else
                    perform  load-already-exist-doc.

       load-new-doc.
           move     lock-stts                   to     file-stts.
           perform  read-fee-file
                    until    file-stts          not =  lock-stts.

           if       file-stts                   =      "23"
                    perform  cler-fee-rec
                    move     "A"                to     run-mode
                    perform  load-dflt-values
           else
                    display  ss-doc-no-synch
                    accept   ss-doc-no-synch
                    display  ss-doc-no-synch.          

           perform  load-edt-dt-tm.

       load-already-exist-doc.
           move     lock-stts                   to     file-stts.
           perform  read-fee-file
                    until    file-stts          not =  lock-stts.

           if       file-stts                   =      "00"
                    move     "C"                to     run-mode
                    move     fr-pay-tp1         to     ws-pay-tp1
                    move     fr-pay-tp2         to     ws-pay-tp2
                    move     fr-pay-tp3         to     ws-pay-tp3
                    move     fr-pay-tp4         to     ws-pay-tp4
                    move     fr-pay-amt1        to     ws-pay-amt1
                    move     fr-pay-amt2        to     ws-pay-amt2
                    move     fr-pay-amt3        to     ws-pay-amt3
                    move     fr-pay-amt4        to     ws-pay-amt4
                    move     fr-chk-no1         to     ws-chk-no1
                    move     fr-chk-no2         to     ws-chk-no2
                    move     fr-chk-no3         to     ws-chk-no3
                    move     fr-chk-no4         to     ws-chk-no4
           else
           if       file-stts                   =      "23"
                    display  ss-fee-not-on-file
                    accept   ss-fee-not-on-file
                    display  ss-erase-err.

           perform  load-edt-dt-tm.
/
       payout-prc.
           move      "Y"                        to       kb-payoff.
           move      14                         to       fld-no.
           perform   entr-fld
                     until    fld-no            >        25.

       updt-bk-pg.
           move      0007                       to      ic-cd-tp.
           move      fr-bk-to-rcd-in            to      ic-id.
           move      fr-rcd-ch                  to      ic-bk-tp-ch-lcn.
           move      lock-stts                  to      file-stts.
           perform   read-ixcd-file
                     until    file-stts         not =   lock-stts.

           if        file-stts                  =       "00"
                     move     "      "          to      ic-locked
                     move     zero              to      ic-locked-by
                     move     fr-end-bk         to      ic-lst-bk-used
                     move     fr-end-pg         to      ic-lst-pg-used
                     move     02                to      file-nmbr
                     rewrite  index-code-record.

           perform  release-code-record.

       unlock-own-bk-pg.
           move     0007                        to      ic-cd-tp.
           move     fr-bk-to-rcd-in             to      ic-id.
           move     fr-rcd-ch                   to      ic-bk-tp-ch-lcn.
           move     lock-stts                   to      file-stts.
           perform  read-ixcd-file
                    until    file-stts          not =   lock-stts.

           if       file-stts                   =       "00"
           and      ic-locked                   =       "LOCKED"
           and      ic-locked-by                =       sttn-nmbr                         
           and      ic-lst-bk-used              =       fr-beg-bk
           and      ic-lst-pg-used              =       fr-beg-pg - 1
                    move     "      "           to      ic-locked
                    move     zero               to      ic-locked-by
                    move     02                 to      file-nmbr
                    rewrite  index-code-record.
           perform  release-code-record.
/
       proc-rcpt.   
           move     space			to	kybd-lasr-rcpt.
           perform  proc-rcpt-qery
                    until	kybd-lasr-rcpt  =       "N".
           perform  proc-rcpt-vldt.                    
                    
       proc-rcpt-qery.  *> Do you want a receipt?  - loop
           display  ss-lasr-rcpt.
           accept   ss-lasr-rcpt.

           display  ss-erase-err.
           if       kybd-lasr-rcpt              =       space
           or       crt-s2			=	zero
                    move   "N"                  to      kybd-lasr-rcpt
           else                    
           if       kybd-lasr-rcpt              =       "Y"
                    perform  print-receipt-swch.                          
               
       proc-rcpt-vldt.                    
           if       fr-bk-to-rcd-in             not =   99                      
                    perform  print-validation-swch
                    move     space              to      kb-validate
                    perform  entr-kb-vldt
                             until   kb-validate =      "N"
                             or      crt-s2	 =      zero.
                             
           if	    dymo-flag			not =   "y"
                    perform  vldt-chck.                                  

       void-mult-tmp.
           if       kb-sngl-mult                =     "M"
           and      run-mode                    not = "A"
                    perform  void-mtmp-record.                          

       void-mtmp-record.
           move     fr-doc-no                   to    mt-doc-no
           move     lock-stts                   to    file-stts
           perform  read-multi-tmp
                    until    file-stts          not = lock-stts.
           if       file-stts                   =     "00"
           and      fr-doc-no                   =     mt-doc-no
                    move     zero               to    mt-amt-due
                    move     03                 to    file-nmbr
                    rewrite  multi-tmp-record.
/

       mp-mult-payoff.
           perform  mp-init.

           perform  mp-dsply-due.

           display  ss-mp-fee-pay-titls.

           move     space                       to   kb-ok.
           perform  mp-entr-revu
                    until    kb-ok              =    "Y"
                    or       kb-ok              =    "C".

           if       kb-ok                       =    "Y"
                    perform  mp-update-control
           else
           if       crt-s2                      =    00
                    display  ss-dflt
                    perform  dsply-brdr
                    perform  dsply-hedr
                    display  ss-sngl-mult               
                    display  ss-fee-titls
                    perform  init-store.

       mp-entr-revu.
           move     999                         to       crt-s2
           move     space                       to       kb-ok.

           display  ss-multi-revu.

           display  ss-mp-ok.
           accept   ss-mp-ok.
           display  ss-mp-ok.

           display  ss-multi-revu.

           if       crt-s2                      =        00
                    move     "C"                to       kb-ok.

           if       crt-s2                      =        10
           and      ws-amt-recd                 >        zero
           and      ws-amt-recd                 <        ws-mult-amt-due
                    display  ss-not-enough-money
                    accept   ss-need-more
                    display  ss-erase-err
                    move     " "                to       kb-ok.

           if       crt-s2                      =        10
           and      ws-amt-recd                 >        zero
           and      ws-amt-recd                 not <    ws-mult-amt-due
                    move     "Y"                to       kb-ok.

           if       crt-s2                        =        10
           and      ws-pay-tp1                    =        "3"
                    move     "Y"                  to       kb-ok.

           if       crt-s2                        =        10
           and      ws-pay-tp1                    =        "4"
                    move     "Y"                  to       kb-ok.

           if       crt-s2                        =        07
                    perform  mp-entr-pymt.

           if       kb-ok                         =        "Y"
                    perform  otpt-fee-rcpt.                          
                                                                     
       otpt-void-rcpt-records.
           perform  load-receipt-no.
           add      01                            to     ws-receipt-no.

           perform  update-ix-receipt-no.

           move     ws-receipt-no                 to     rc-receipt-no.
           move     sys-yr                        to     rc-year.
           add      1900                          to     rc-year.
           move     sys-mt                        to     rc-month.
           move     sys-dy                        to     rc-day.

           move     fr-receipt-no                 to     rc-void-note.

           move     space                         to     rc-login-name.
           move     kb-clk-id                     to     rc-clk-id.
           move     kb-clctn-ch                   to     rc-ch.
           move     space                         to     rc-filler.
           move     04                            to     file-nmbr.

           move     01                            to     rc-consec-no.
           move     "1"                           to     rc-payment-type.
           move     zero                          to     rc-payment-amount.
           display  fr-amt-due                    at     2301
           subtract fr-amt-due                    from   0
                                                  giving rc-payment-amount
           move     "void"                        to     rc-check-no
           write    fee-receipt-record
                    invalid  key
                             move     "22"        to     file-stts.
                                                                                   
       otpt-fee-rcpt.  
           perform  load-receipt-no.                                          
           add      01                            to   ws-receipt-no.

           perform  update-ix-receipt-no.        
                                                                              
           move     ws-receipt-no                 to   rc-receipt-no.
           move     sys-yr                        to   rc-year.
           add      1900                          to   rc-year.
           move     sys-mt                        to   rc-month.             
           move     sys-dy                        to   rc-day.

           move     space                         to   rc-void-note.
           move     space                         to   rc-login-name.
           move     kb-clk-id                     to   rc-clk-id.
           move     kb-clctn-ch                   to   rc-ch.
           move     space                         to   rc-filler.
           move     04                            to   file-nmbr.


           if       ws-pay-tp1                    =    "3"
           and      kb-sngl-mult                  =    "S"
                    move     01                   to   rc-consec-no
                    move     ws-pay-tp1           to   rc-payment-type
                    move     fr-amt-due           to   rc-payment-amount
                    move     ws-chk-no1           to   rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move     "22"
                                                  to   file-stts
           else
           if       ws-pay-tp1                    =    "3"
           and      kb-sngl-mult                  =    "M"
                    move     01                   to   rc-consec-no
                    move     ws-pay-tp1           to   rc-payment-type
                    move     ws-mult-amt-due      to   rc-payment-amount
                    move     ws-chk-no1           to   rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move     "22"
                                                  to   file-stts
           else
           if       ws-pay-tp1                    =    "4"
                    move     01                   to   rc-consec-no
                    move     ws-pay-tp1           to   rc-payment-type
                    move     ws-pay-amt1          to   rc-payment-amount
                    move     ws-chk-no1           to   rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move    "22"
                                                  to    file-stts
           else
           if       ws-pay-amt1                   not = zero
                    move     01                   to    rc-consec-no
                    move     ws-pay-tp1           to    rc-payment-type
                    move     ws-pay-amt1          to    rc-payment-amount
                    move     ws-chk-no1           to    rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move    "22"
                                                  to    file-stts.

           if       ws-pay-amt2                   not = zero
                    move     02                   to    rc-consec-no
                    move     ws-pay-tp2           to    rc-payment-type
                    move     ws-pay-amt2          to    rc-payment-amount
                    move     ws-chk-no2           to    rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move    "22"
                                                  to    file-stts.
           if       ws-pay-amt3                   not = zero
                    move     03                   to    rc-consec-no
                    move     ws-pay-tp3           to    rc-payment-type
                    move     ws-pay-amt3          to    rc-payment-amount
                    move     ws-chk-no3           to    rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move    "22"
                                                  to    file-stts.
           if       ws-pay-amt4                   not = zero
                    move     04                   to    rc-consec-no
                    move     ws-pay-tp4           to    rc-payment-type
                    move     ws-pay-amt4          to    rc-payment-amount
                    move     ws-chk-no4           to    rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move    "22"
                                                  to    file-stts.
           if       ws-pay-amt5                   not = zero
                    move     05                   to    rc-consec-no
                    move     ws-pay-tp5           to    rc-payment-type
                    move     ws-pay-amt5          to    rc-payment-amount
                    move     ws-chk-no5           to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.
           if       ws-pay-amt6                   not = zero
                    move     06                   to    rc-consec-no
                    move     ws-pay-tp6           to    rc-payment-type
                    move     ws-pay-amt6          to    rc-payment-amount
                    move     ws-chk-no6           to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.
           if       ws-pay-amt7                   not = zero
                    move     07                   to    rc-consec-no
                    move     ws-pay-tp7           to    rc-payment-type
                    move     ws-pay-amt7          to    rc-payment-amount
                    move     ws-chk-no7           to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.
           if       ws-pay-amt8                   not = zero
                    move     08                   to    rc-consec-no
                    move     ws-pay-tp8           to    rc-payment-type
                    move     ws-pay-amt8          to    rc-payment-amount
                    move     ws-chk-no8           to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.
           if       ws-pay-amt9                   not = zero
                    move     09                   to    rc-consec-no
                    move     ws-pay-tp9           to    rc-payment-type
                    move     ws-pay-amt9          to    rc-payment-amount
                    move     ws-chk-no9           to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.
           if       ws-pay-amt10                  not = zero
                    move     10                   to    rc-consec-no
                    move     ws-pay-tp10          to    rc-payment-type
                    move     ws-pay-amt10         to    rc-payment-amount
                    move     ws-chk-no10          to    rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move     "22"
                                                  to    file-stts.

           if       ws-pay-amt11                  not = zero
                    move     11                   to    rc-consec-no
                    move     ws-pay-tp11          to    rc-payment-type
                    move     ws-pay-amt11         to    rc-payment-amount
                    move     ws-chk-no11          to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.

           if       ws-pay-amt12                  not = zero
                    move     12                   to    rc-consec-no
                    move     ws-pay-tp12          to    rc-payment-type
                    move     ws-pay-amt12         to    rc-payment-amount
                    move     ws-chk-no12          to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.

           if       ws-pay-amt13                  not = zero
                    move     13                   to    rc-consec-no
                    move     ws-pay-tp13          to    rc-payment-type
                    move     ws-pay-amt13         to    rc-payment-amount
                    move     ws-chk-no13          to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.

           if       ws-pay-amt14                  not = zero
                    move     14                   to    rc-consec-no
                    move     ws-pay-tp14          to    rc-payment-type
                    move     ws-pay-amt14         to    rc-payment-amount
                    move     ws-chk-no14          to    rc-check-no
                    write    fee-receipt-record
                             invalid key
                                     move     "22"
                                                  to    file-stts.

           if       ws-change                     >     zero
           and      ws-pay-tp1                    not = "4"
           and      ws-pay-tp1                    not = "3"
                    add     01                    to    rc-consec-no
                    move    "1"                   to    rc-payment-type
                    subtract ws-change            from  0
                                                  giving rc-payment-amount
                    move     "change"             to    rc-check-no
                    write    fee-receipt-record
                             invalid  key
                                      move    "22" to    file-stts.

       load-receipt-no.
           move     0013                         to    ic-cd-tp.
           move     "RCP"                        to    ic-id.
           move     lock-stts                    to    file-stts.
           perform  read-ixcd-file
                    until     file-stts          not = lock-stts.
           if       file-stts                    =     "00"
                    move     ic-nxt-rcpt-no      to    ws-receipt-no
           else
                    move     zero                to    ws-receipt-no
                    display  "CANNOT FIND RECEIPT #"
                                                 at    2305
                    stop     " ".

       update-ix-receipt-no.
           move     0013                         to    ic-cd-tp.
           move     "RCP"                        to    ic-id.
           move     lock-stts                    to    file-stts.
           perform  read-ixcd-file
                    until file-stts              not = lock-stts.
           if       file-stts                    =     "00"
                    move     ws-receipt-no       to    ic-nxt-rcpt-no-num
                    move     02                  to    file-nmbr
                    rewrite  ic-nxt-rcpt-no-record.

       mp-entr-pymt.
           perform  mp-clear-pay-flds.
           display  ss-mp-fee-pay-titls.
           display  ss-mp-amt-due.
           display  ss-mp-pay-flds.

           move     14                            to    fld-no.
           perform  entr-fld
                    until     fld-no              >     55.
/
       mp-clear-pay-flds.
           initialize ws-pay-flds.

       mp-update-control.
           perform  print-mult-payoff-receipt-swch.
           if	    dymo-flag			  not = "y"
                    perform   vldt-chck.
           perform  mp-updt-fee-amt.

           move     space                         to    kb-ok.
           move     space                         to    run-mode.
           move     space                         to    kb-sngl-mult.
           move     space                         to    kb-payoff.

           move     03                            to    file-nmbr.
           close    multi-tmp.
           open     output multi-tmp.

           display  ss-dflt.
           perform  dsply-brdr.
           perform  dsply-hedr.
           display  ss-fee-titls.

           perform  init-store.

           perform  entr-sngl-mult.

       mp-updt-fee-amt.
           move     03                            to    file-nmbr.
           close    multi-tmp.
           open     i-o      multi-tmp.
           perform  mp-inpt-mtmp-next
                    until    file-stts            =     "10".

       mp-inpt-mtmp-next.
           move     03                            to    file-nmbr.
           read     multi-tmp
                    next
                    at       end
                             move     "10"        to    file-stts.
           if       file-stts                     =     "00"
                    perform   mp-inpt-fee-rec.
/
       mp-inpt-fee-rec.
           move     mt-doc-no                     to    fr-doc-no.
           move     lock-stts                     to    file-stts.
           perform  read-fee-file
                    until    file-stts            not = lock-stts.
           if       file-stts                     =     "00"
                    perform  mp-load-amt-pd.

       mp-load-amt-pd.
           if       fr-amt-due                    not = mt-amt-due
           and      ws-pay-tp1                    not = "3"
           and      ws-pay-tp1                    not = "4"
                    display "AMOUNT DUE NOT = ANYMORE"
                                                  at    2305
                    accept  nul-entry             at    0000.
           if       ws-pay-tp1                    =     "3"
           or       ws-pay-tp1                    =     "4"
                    move     zero                 to    fr-amt-recd
                    move     ws-receipt-no        to    fr-receipt-no
                    perform  rewrite-fee-record
           else
                    move     fr-amt-due           to    fr-amt-recd
                    move     ws-receipt-no        to    fr-receipt-no
                    perform  rewrite-fee-record.

       mp-init.
           display  ss-dflt.
           perform  dsply-brdr.
           perform  dsply-hedr.
           display  ss-multi-pay-titles.
           perform  cler-pay-flds.

           move     03                            to    file-nmbr.
           close    multi-tmp.
           open     i-o      multi-tmp.
           move     06                            to    ln-no.
           move     zero                          to    ws-mult-amt-due.
           move     zero                          to    ws-mult-doc-cnt.
           move     "Y"                           to    kb-payoff.
/
       mp-dsply-due.
           move     space                         to    file-stts.
           perform  mp-inpt-mtmp
                    until    file-stts            =     "10".

           add      02                            to    ln-no.
           display  ss-multi-amt-due.

       mp-inpt-mtmp.
           move     03                            to    file-nmbr.
           read     multi-tmp
                    next
                    at       end
                             move      "10"       to    file-stts.
           if       file-stts                     =     "00"
                    perform  mp-dsply-amt-due.

       mp-dsply-amt-due.
           if       ln-no                         >     18
                    display  "Press any key to continue "
                                                  at    0020
                    accept   nul-entry            at    0000
                    display  ss-cler-mult-data
                    move     06                   to    ln-no.

           add      01                            to    ln-no.
           display  ss-multi-data.
           add      mt-amt-due                    to    ws-mult-amt-due.
           add      01                            to    ws-mult-doc-cnt.
/
       vldt-chck.
       
       vldt-chck-zzzzzzzz.
           if       ws-pay-tp1                  =     "0"          
                    perform  vldt-chck-proc.
           if       ws-pay-tp2                  =     "0"
                    perform  vldt-chck-proc.
           if       ws-pay-tp3                  =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp4                  =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp5                  =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp6                  =     "0"
                    perform  vldt-chck-proc.                      

           if       ws-pay-tp7                  =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp8                  =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp9                  =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp10                 =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp11                 =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp12                 =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp13                 =     "0"
                    perform  vldt-chck-proc.

           if       ws-pay-tp14                 =     "0"
                    perform  vldt-chck-proc.

                    
           move     space                       to   kb-vl-chks.
           if       ws-pay-tp1                  =    "0"
           or       ws-pay-tp2                  =    "0"
           or       ws-pay-tp3                  =    "0"
           or       ws-pay-tp4                  =    "0"
           or       ws-pay-tp5                  =    "0"
           or       ws-pay-tp6                  =    "0"
           or       ws-pay-tp7                  =    "0"
           or       ws-pay-tp8                  =    "0"
           or       ws-pay-tp9                  =    "0"
           or       ws-pay-tp10                 =    "0"
           or       ws-pay-tp11                 =    "0"
           or       ws-pay-tp12                 =    "0"
           or       ws-pay-tp13                 =    "0"
           or       ws-pay-tp14                 =    "0"
                    perform  vldt-chck-entr.
                    
       vldt-chck-entr.
           move     space                    to    kb-vl-chks.
           display  ss-vl-another-check.
           accept   ss-vl-another-check.
           display  ss-erase-err.
           if       kb-vl-chks               =     space
                    move     "N"             to    kb-vl-chks.

           if       kb-vl-chks               =     "Y"
                    perform  vldt-chck-proc.

       vldt-chck-proc.
           perform  release-code-record.
           open     output   itca-file.
           write    itca-rcrd                from  "&%VO".
           close    itca-file.

           move     space                    to    nul-entry.
           display  ss-vldt-chck.
           accept   ss-vldt-chck.
           display  ss-erase-err.

           open     output   itca-file.
           
           write    itca-rcrd                from  "&%VC".
           close    itca-file.

           open     output   itca-file.

           perform  prnt-itca                05    times.
           move     fr-receipt-no            to    detl-itca-line.
           perform  prnt-itca                03    times.
           move     "FOR DEPOSIT ONLY"       to    detl-itca-line.
           perform  prnt-itca.
           move     ws-offc-name             to    detl-itca-line.
           perform  prnt-itca.
           string   ws-offcl-name
                    delimited                by    "  "
                    ", "
                    delimited                by    size
                    ws-offcl-title
                    delimited                by    "  "
                                             into  detl-itca-line.
           perform  prnt-itca.

           move     edt-clctn-bank-name      to    detl-itca-titl.

           if       fr-doc-cls               =     20
           and      kb-clctn-ch              =     "N"
                    move   "Acct#   AUTO 0064452"
                                             to    detl-itca-desc
           else
                    string   "Acct# "                            
                    delimited                by    size
                    edt-clctn-acct-no
                    delimited                by    size
                                             into  detl-itca-desc.
           perform  prnt-itca             03    times.

           close    itca-file.
                    

       load-dflt-values.
           accept   sys-date                      from  date.
           accept   sys-time                      from  time.
           accept   julian-date                   from  day.
           move     sys-time                      to    fr-doc-time.
           move     sys-mt                        to    fr-doc-mt.
           move     sys-dy                        to    fr-doc-dy.
           move     sys-yr                        to    fr-doc-yr.
           if       sys-yr                        >     90
                    move     19                   to    fr-doc-cn
           else
                    move     20                   to    fr-doc-cn.
           move     kb-clk-id                     to    fr-clk-id.
           move     kb-clctn-ch                   to    fr-clctn-ch.
           move     kb-sngl-mult                  to    fr-sngl-mult.
           move     01                            to    fr-count.

        load-edt-dt-tm.
           move     fr-doc-dy                     to    edt-dy.
           move     fr-doc-mt                     to    edt-mt.
           move     fr-doc-yr                     to    edt-yr.
           move     fr-doc-cn                     to    edt-cn.
           if       fr-doc-hr                     >     11
                    move     "pm"                 to    edt-mr
           else
                    move     "am"                 to    edt-mr.
           if       fr-doc-hr                     >     12
                    add      -12                  to    fr-doc-hr.
           move     fr-doc-hr                     to    edt-hr.
           move     fr-doc-mn                     to    edt-mn.
           move     fr-doc-sc                     to    edt-sc.

       load-next-doc-no.
           move     0010                          to    ic-cd-tp.
           move     "DOC"                         to    ic-id.
           move     lock-stts                     to    file-stts.
           move     02                            to    file-nmbr.
           perform  read-ixcd-file
                    until    file-stts            not = lock-stts.

           if       file-stts                     =     "00"
           and      ic-nxt-doc-no-dy              =     sys-dy
           and      ic-nxt-doc-no-yr              =     sys-yr
           and      ic-nxt-doc-no-mt              =     sys-mt
                    next sentence
           else
                    display  ss-doc-no-wrong
                    accept   ss-doc-no-wrong.

           if       file-stts                     not = "00"
                    display  ss-missing-doc-no
                    accept   ss-missing-doc-no
           else
                    move     ic-nxt-doc-no        to    fr-doc-no
                    display  ss-key
                    perform  update-next-doc-no.

       update-next-doc-no.
           add      01                           to    ic-nxt-doc-no
           move     02                           to    file-nmbr.
           rewrite  ic-nxt-doc-no-record.
/
       entr-fld.
           if       fld-no                       =     01
                    perform entr-fld-3.
           if       fld-no                       =     02
                    perform entr-fld-4.
           if       fld-no                       =     03
                    perform entr-fld-5.
           if       fld-no                       =     04
                    perform entr-fld-6.
           if       fld-no                       =     05
                    perform entr-fld-1.
           if       fld-no                       =     06
                    perform entr-fld-2.
           if       fld-no                       =     07
*          and      run-mode                     =     "A"
                    perform entr-fld-7.
           if       fld-no                       =     08
           and      ws-trnsf-tax-flg             =     "Y"
                    perform entr-fld-8
           else
           if       kb-payoff                    not = "Y"
                    display ss-fld-8.
           if       fld-no                       =     11
           and      fr-doc-tp                    =     "POST"
                    perform entr-fld-11.
           if       fld-no                       =     12
           and      ws-trnsf-tax-flg             =     "Y"
           and      fr-valuation                 >     zero
                    perform entr-fld-12.
           if       fld-no                       =     13
                    perform entr-fld-13
                    perform entr-fld-13a.
           if       crt-s2                       =     zero
           and      kb-payoff                    not = "Y"
           and      run-mode                     =     "A"
                    move     27                  to    fld-no
                    move     "V"                 to    kb-ok.
           if       kb-ok                        =     "N"
           and      run-mode                     not = "A"
                    next sentence
           else
           if       fr-sngl-mult                 =     "S"
           or       kb-payoff                    =     "Y"
                    perform entr-pay-flds.

           if       crt-s2                       =     05
                    perform bck-fld
           else
           if       fld-no                       <     14
                    perform vldt-fld.

           perform  calc-amt-due.

           if       kb-ok                        =     "N"
           and      run-mode                     not = "A"
                    next sentence
           else
           if       kb-sngl-mult                 not = "M"
                    perform calc-sngl-payment
           else
                    perform calc-mult-payment.

           if       kb-ok                        =     "N"
           and      run-mode                     not = "A"
                    next     sentence
           else
           if       kb-sngl-mult                 not = "M"
                    display  ss-fee-amts
                    display  ss-chng-rvrs
           else
           if       kb-sngl-mult                 not = "M"
           or       kb-payoff                    not = "Y"
                    display  ss-rcd-fees
           else
           if       kb-payoff                    =     "Y"
           and      kb-sngl-mult                 =     "M"
                    display  ss-mp-amt-due
                    display  ss-mp-chng-rvrs
           else
           if       kb-payoff                    =     "Y"
                    display  ss-pay-flds
                    display  ss-chng-rvrs.
           add      01                           to    fld-no.
/
       entr-pay-flds.
           if       fr-amt-recd                  not < fr-amt-due
           and      fr-amt-due                   not = zero
           and      fld-no                       not = 16
           and      fld-no                       not = 19
           and      fld-no                       not = 22
           and      fld-no                       not = 25
           and      fld-no                       >     16
           and      kb-sngl-mult                 not = "M"
                    move     27                  to    fld-no.

           if       ws-amt-recd                  not < ws-mult-amt-due
           and      ws-mult-amt-due              not = zero
           and      fld-no                       not = 16
           and      fld-no                       not = 19
           and      fld-no                       not = 22
           and      fld-no                       not = 25
           and      fld-no                       not = 28
           and      fld-no                       not = 31
           and      fld-no                       not = 34
           and      fld-no                       not = 37
           and      fld-no                       not = 40
           and      fld-no                       not = 43
           and      fld-no                       not = 46
           and      fld-no                       not = 49
           and      fld-no                       not = 52
           and      fld-no                       not = 55
           and      fld-no                       >     16
           and      kb-sngl-mult                 =     "M"
                    move  60                     to    fld-no.

           if       fld-no                       >     55
           and      ws-change                    <     zero
           and      crt-s2                       not = zero
                    display ss-need-more
                    accept  ss-need-more
                    display ss-erase-err
                    move    13                   to    fld-no.

           if       fld-no                       =     14
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    perform cler-pay-flds
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-14
                    display ss-erase-err
           else
           if       fld-no                       =     14
                    perform cler-pay-flds
                    display ss-vld-pay-tp
                    perform entr-fld-14
                    display ss-erase-err.
           if       fld-no                       =     15
                    perform entr-fld-15.

           if       fld-no                       =     16
           and      ws-pay-tp1                   =     "0"
                    perform entr-fld-16
           else
           if       fld-no                       =     16
           and      ws-pay-tp1                   =     "2"
                    perform entr-fld-16
           else
           if       fld-no                       =     16
                    move    space                to    ws-chk-no1.

           if       fld-no                       =     17
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-17
                    display ss-erase-err
           else
           if       fld-no                       =     17
                    display ss-vld-pay-tp
                    perform entr-fld-17
                    display ss-erase-err.
           if       fld-no                       =     18
                    perform entr-fld-18.
           if       fld-no                       =     19
           and      ws-pay-tp2                   =     "0"
                    perform entr-fld-19
           else
           if       fld-no                       =     19
           and      ws-pay-tp2                   =     "2"
                    perform entr-fld-19
           else
           if       fld-no                       =     19
                    move    space                to    ws-chk-no2.
           if       fld-no                       =     20
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-20
                    display ss-erase-err
           else
           if       fld-no                       =     20
                    display ss-vld-pay-tp
                    perform entr-fld-20
                    display ss-erase-err.
           if       fld-no                       =     21
                    perform entr-fld-21.
           if       fld-no                       =     22
           and      ws-pay-tp3                   =     "0"
                    perform entr-fld-22
           else
           if       fld-no                       =     22
           and      ws-pay-tp3                   =     "2"
                    perform entr-fld-22
           else
           if       fld-no                       =     22
                    move    space                to    ws-chk-no3.
           if       fld-no                       =     23
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-23
                    display ss-erase-err
           else
           if       fld-no                       =     23
                    display ss-vld-pay-tp
                    perform entr-fld-23
                    display ss-erase-err.
           if       fld-no                       =     24
                    perform entr-fld-24.
           if       fld-no                       =     25
           and      ws-pay-tp4                   =     "0"
                    perform entr-fld-25
           else
           if       fld-no                       =     25
           and      ws-pay-tp4                   =     "2"
                    perform entr-fld-25
           else
           if       fld-no                       =     25
                    move    space                to    ws-chk-no4.

           if       fld-no                       =     26
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-26
                    display ss-erase-err
           else
           if       fld-no                       =     26
                    display ss-vld-pay-tp
                    perform entr-fld-26
                    display ss-erase-err.

           if       fld-no                       =     27
                    perform entr-fld-27.

           if       fld-no                       =     28
           and      ws-pay-tp5                   =     "0"
                    perform entr-fld-28
           else
           if       fld-no                   	 =     28
           and      ws-pay-tp5               	 =     "2"
                    perform entr-fld-28      	 
           else                              	 
           if       fld-no                   	 =     28
                    move    space            	 to    ws-chk-no4.
           if       fld-no                   	 =     29
*          and                               	       kenton
*          and      swch-nmbr(01)            	 =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-29
                    display ss-erase-err
           else
           if       fld-no                       =     29
                    display ss-vld-pay-tp        
                    perform entr-fld-29          
                    display ss-erase-err.        
           if       fld-no                       =     30
                    perform entr-fld-30.         
           if       fld-no                       =     31
           and      ws-pay-tp6                   =     "0"
                    perform entr-fld-31          
           else                                  
           if       fld-no                       =     31
           and      ws-pay-tp6                   =     "2"
                    perform entr-fld-31          
           else                                  
           if       fld-no                       =     31
                    move    space                to    ws-chk-no4.
                                                 
           if       fld-no                       =     32
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-32
                    display ss-erase-err
           else
           if       fld-no                       =     32
                    display ss-vld-pay-tp        
                    perform entr-fld-32          
                    display ss-erase-err.        
           if       fld-no                       =     33
                    perform entr-fld-33.         
           if       fld-no                       =     34
           and      ws-pay-tp7                   =     "0"
                    perform entr-fld-34          
           else                                  
           if       fld-no                       =     34
           and      ws-pay-tp7                   =     "2"
                    perform entr-fld-34          
           else                                  
           if       fld-no                       =     34
                    move    space                to    ws-chk-no4.
                                                 
           if       fld-no                       =     35
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-35
                    display ss-erase-err
           else
           if       fld-no                       =     35
                    display ss-vld-pay-tp        
                    perform entr-fld-35          
                    display ss-erase-err.        
           if       fld-no                       =     36
                    perform entr-fld-36.         
           if       fld-no                       =     37
           and      ws-pay-tp8                   =     "0"      
                    perform entr-fld-37          
           else                                  
           if       fld-no                       =     37
           and      ws-pay-tp8                   =     "2"
                    perform entr-fld-37          
           else                                  
           if       fld-no                       =     37
                    move    space                to    ws-chk-no4.
           if       fld-no                       =     38
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-38
                    display ss-erase-err
           else
           if       fld-no                       =     38
                    display ss-vld-pay-tp        
                    perform entr-fld-38          
                    display ss-erase-err.        
           if       fld-no                       =     39
                    perform entr-fld-39.         
           if       fld-no                       =     40
           and      ws-pay-tp9                   =     "0"
                    perform entr-fld-40          
           else                                  
           if       fld-no                       =     40
           and      ws-pay-tp9                   =     "2"
                    perform entr-fld-40          
           else                                  
           if       fld-no                       =     40
                    move    space                to    ws-chk-no4.
           if       fld-no                       =     41
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-41
                    display ss-erase-err
           else
           if       fld-no                       =     41
                    display ss-vld-pay-tp        
                    perform entr-fld-41          
                    display ss-erase-err.        
           if       fld-no                       =     42
                    perform entr-fld-42.         
           if       fld-no                       =     43
           and      ws-pay-tp10                  =     "0"
                    perform entr-fld-43          
           else                                  
           if       fld-no                       =     43
           and      ws-pay-tp10                  =     "2"
                    perform entr-fld-43          
           else                                  
           if       fld-no                       =     43
                    move    space                to    ws-chk-no4.
                                                 
           if       fld-no                       =     44
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-44
                    display ss-erase-err
           else
           if       fld-no                       =     44
                    display ss-vld-pay-tp        
                    perform entr-fld-44          
                    display ss-erase-err.        
           if       fld-no                       =     45
                    perform entr-fld-45.         
                                                 
           if       fld-no                       =     46
           and      ws-pay-tp11                  =     "0"
                    perform entr-fld-46          
           else                                  
           if       fld-no                       =     46
           and      ws-pay-tp11                  =     "2"
                    perform entr-fld-46          
           else                                  
           if       fld-no                       =     46
                    move    space                to    ws-chk-no4.
           if       fld-no                       =     47
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-47                           
                    display ss-erase-err
           else
           if       fld-no                       =     47
                    display ss-vld-pay-tp        
                    perform entr-fld-47          
                    display ss-erase-err.        
           if       fld-no                       =     48
                    perform entr-fld-48.         
                                                 
           if       fld-no                       =     49
           and      ws-pay-tp12                  =     "0"
                    perform entr-fld-49          
           else                                  
           if       fld-no                       =     49
           and      ws-pay-tp12                  =     "2"
                    perform entr-fld-49          
           else                                  
           if       fld-no                       =     49
                    move    space                to    ws-chk-no4.
                                                 
           if       fld-no                       =     50
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-50
                    display ss-erase-err
           else
           if       fld-no                       =     50
                    display ss-vld-pay-tp        
                    perform entr-fld-50          
                    display ss-erase-err.        
                                                 
           if       fld-no                       =     51
                    perform entr-fld-51.         
                                                 
           if       fld-no                       =     52
           and      ws-pay-tp13                  =     "0"
                    perform entr-fld-52          
           else                                  
           if       fld-no                       =     52
           and      ws-pay-tp13                  =     "2"
                    perform entr-fld-52          
           else                                  
           if       fld-no                       =     52
                    move    space                to    ws-chk-no4.
                                                 
           if       fld-no                       =     53
*          and                                         kenton
*          and      swch-nmbr(01)                =     "+"
                    display ss-kenton-vld-pay-tp
                    perform entr-fld-53
                    display ss-erase-err
           else
           if       fld-no                       =     53
                    display ss-vld-pay-tp        
                    perform entr-fld-53          
                    display ss-erase-err.        
                                                 
           if       fld-no                       =     54
                    perform entr-fld-54.         
                                                 
           if       fld-no                       =     55
           and      ws-pay-tp14                  =     "0"
                    perform entr-fld-55          
           else                                  
           if       fld-no                       =     55
           and      ws-pay-tp14                  =     "2"
                    perform entr-fld-55          
           else                                  
           if       fld-no                       =     55
                    move    space                to    ws-chk-no4.

           perform  vldt-fld.
/
       entr-fld-1.
           display  ss-fld-1.
           accept   ss-fld-1.
           display  ss-fld-1.

       entr-fld-2.
           display  ss-fld-2.
           accept   ss-fld-2.
           display  ss-fld-2.

       entr-fld-3.
           display  ss-bp1-titl.
           display  ss-fld-3.
           accept   ss-fld-3.
           display  ss-fld-3.

       entr-fld-4.
           if       fr-name-tp1              not = "B"
                    perform entr-fml-name1
           else
                    perform entr-bus-name1.

       entr-fml-name1.
           string   fr-frst-name1  delimited by "  "
                    " "            delimited by size
                    fr-midl-name1  delimited by "  "
                    " "            delimited by size
                    fr-last-name1  delimited by "  "
                                             into  ws-nam1.


           move     "Enter  First  Mid  Last"
                                             to    ws-fml1-dir.
           display  ss-fld-4-fml.
           accept   ss-fld-4-fml.
           move     ws-nam1                  to    ws-nam.
           perform  look-for-period.
           perform  unstg-p-nam-1.
           move     space                    to    ws-fml1-dir.
           display  ss-fld-4-fml.

       entr-bus-name1.
           display  ss-fld-4.
           accept   ss-fld-4.
           move     0011                     to    ic-cd-tp.
           move     fr-name1                 to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until   file-stts        not = lock-stts.
           if       file-stts                =     "00"
                    move ic-cmn-name         to    fr-name1.
           display  ss-fld-4.
           move     fr-name1                 to    ws-nam.
           perform  look-for-period.

       entr-fld-5.
           display  ss-bp2-titl.
           display  ss-fld-5.
           accept   ss-fld-5.
           display  ss-fld-5.
/
       entr-fld-6.
           display  ss-fld-6.
           if       fr-name-tp2              not = "B"
                    perform entr-fml-name2
           else
                    perform entr-bus-name2.

       entr-fml-name2.
           string   fr-frst-name2  delimited by "  "
                    " "            delimited by size
                    fr-midl-name2  delimited by "  "
                    " "            delimited by size
                    fr-last-name2  delimited by "  "
                                             into  ws-nam2.


           move     "Enter  First  Mid  Last"
                                             to   ws-fml2-dir.
           display  ss-fld-6-fml.
           accept   ss-fld-6-fml.
           display  ss-fld-6-fml.
           move     ws-nam2                  to   ws-nam.
           perform  look-for-period.
           perform  unstg-p-nam-2.
           move     space                    to   ws-fml2-dir.
           display  ss-fld-6-fml.

       entr-bus-name2.
           accept   ss-fld-6.
           move     0011                     to    ic-cd-tp.
           move     fr-name2                 to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until   file-stts        not = lock-stts.
           if       file-stts                =     "00"
                    move ic-cmn-name         to    fr-name2.
           display  ss-fld-6.
           move     fr-name2                 to    ws-nam.
           perform  look-for-period.

       entr-fld-7.
           if       fr-doc-cls               =     20
           and      fr-doc-tp                =     "UCC1"
                    move     01              to    fr-no-pages
                    perform  cont-entr-fld-7
           else
           if       fr-doc-cls               =     20
           and      fr-doc-tp                =     "UCC-SE"
                    move     01              to    fr-no-pages
                    perform  cont-entr-fld-7
           else
           if       fr-doc-cls               =     20
           and      fr-doc-tp                =     "MVLS"
                    move     01              to    fr-no-pages
                    perform  cont-entr-fld-7
           else
           if       fr-doc-cls               =     20
           and      fr-doc-tp                =     "MHLS"
                    move     01              to    fr-no-pages
                    perform  cont-entr-fld-7
           else
           if       fr-doc-cls               =     20
                    move     01              to    fr-no-pages
                    perform  enter-old-file-no
           else
                    perform  cont-entr-fld-7.

       enter-old-file-no.
           display  ss-edt-file-no.
           display  ss-file-no.
           accept   ss-file-no.
           display  ss-file-no.

       cont-entr-fld-7.
           display  ss-fld-7.
           accept   ss-fld-7.
           display  ss-fld-7.
*
*          if       fr-doc-cls               not = 20
*          and                               not   kenton
*          and      swch-nmbr(01)            not = "+"
*                   display  ss-fld-7
*                   accept   ss-fld-7
*                   display  ss-fld-7.

           if       fr-no-pages              >     30
                    display  ss-ovr-30-pgs
                    accept   ss-ovr-30-pgs
                    display  ss-erase-err.

           if       crt-s2                   =     05
                    perform  unlock-own-bk-pg
           else
                    perform  load-lock-bk-pg.

           if       fr-doc-cls               =     20
                    display  ss-edt-file-no
           else
                    display  ss-fld-7
                    display  ss-edt-7.
/
       entr-fld-8.
           move     fr-valuation             to    ws-valuation.
           display  ss-fld-8.
           accept   ss-fld-8.
           move     ws-valuation             to    fr-valuation.
           display  ss-fld-8.

       entr-fld-9.
           display  ss-fld-9.
           accept   ss-fld-9.
           display  ss-fld-9.

       entr-fld-10.
           display  ss-fld-10.
           accept   ss-fld-10.
           display  ss-fld-10.

       entr-fld-11.
           display  ss-fld-11.
           accept   ss-fld-11.
           display  ss-fld-11.

       entr-fld-12.
           display  ss-fld-12.
           accept   ss-fld-12.
           display  ss-fld-12.

       entr-fld-13.
           display  ss-fld-13.
           accept   ss-fld-13.
           display  ss-fld-13.

       entr-fld-13a.
           display  ss-fld-13a.
           accept   ss-fld-13a.
           display  ss-fld-13a.

/
       entr-fld-14.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-14
                    accept   ss-mp-fld-14
           else
                    display  ss-fld-14
                    accept   ss-fld-14.

           if       crt-s2                   =    05
           and      kb-sngl-mult             =    "M"
                    add      01              to   fld-no.

           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-14
           else
                    display  ss-fld-14.

       entr-fld-15.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-15
                    accept   ss-mp-fld-15
                    display  ss-mp-fld-15
           else
                    display  ss-fld-15
                    accept   ss-fld-15
                    display  ss-fld-15.

       entr-fld-16.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-16
                    accept   ss-mp-fld-16
                    display  ss-mp-fld-16
           else
                    display  ss-fld-16
                    accept   ss-fld-16
                    display  ss-fld-16.

       entr-fld-17.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-17
                    accept   ss-mp-fld-17
                    display  ss-mp-fld-17
           else
                    display  ss-fld-17
                    accept   ss-fld-17
                    display  ss-fld-17.

       entr-fld-18.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-18
                    accept   ss-mp-fld-18
                    display  ss-mp-fld-18
           else
                    display  ss-fld-18
                    accept   ss-fld-18
                    display  ss-fld-18.

       entr-fld-19.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-19
                    accept   ss-mp-fld-19
                    display  ss-mp-fld-19
           else
                    display  ss-fld-19
                    accept   ss-fld-19
                    display  ss-fld-19.

       entr-fld-20.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-20
                    accept   ss-mp-fld-20
                    display  ss-mp-fld-20
           else
                    display  ss-fld-20
                    accept   ss-fld-20
                    display  ss-fld-20.

       entr-fld-21.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-21
                    accept   ss-mp-fld-21
                    display  ss-mp-fld-21
           else
                    display  ss-fld-21
                    accept   ss-fld-21
                    display  ss-fld-21.

       entr-fld-22.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-22
                    accept   ss-mp-fld-22
                    display  ss-mp-fld-22
           else
                    display  ss-fld-22
                    accept   ss-fld-22
                    display  ss-fld-22.

       entr-fld-23.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-23
                    accept   ss-mp-fld-23
                    display  ss-mp-fld-23
           else
                    display  ss-fld-23
                    accept   ss-fld-23
                    display  ss-fld-23.

       entr-fld-24.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-24
                    accept   ss-mp-fld-24
                    display  ss-mp-fld-24
           else
                    display  ss-fld-24
                    accept   ss-fld-24
                    display  ss-fld-24.

       entr-fld-25.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-25
                    accept   ss-mp-fld-25
                    display  ss-mp-fld-25
           else
                    display  ss-fld-25
                    accept   ss-fld-25
                    display  ss-fld-25.
/
       entr-fld-26.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-26
                    accept   ss-mp-fld-26
                    display  ss-mp-fld-26.
       entr-fld-27.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-27
                    accept   ss-mp-fld-27
                    display  ss-mp-fld-27.
       entr-fld-28.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-28
                    accept   ss-mp-fld-28
                    display  ss-mp-fld-28.
       entr-fld-29.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-29
                    accept   ss-mp-fld-29
                    display  ss-mp-fld-29.
       entr-fld-30.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-30
                    accept   ss-mp-fld-30
                    display  ss-mp-fld-30.
       entr-fld-31.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-31
                    accept   ss-mp-fld-31
                    display  ss-mp-fld-31.
       entr-fld-32.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-32
                    accept   ss-mp-fld-32
                    display  ss-mp-fld-32.
       entr-fld-33.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-33
                    accept   ss-mp-fld-33
                    display  ss-mp-fld-33.
       entr-fld-34.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-34
                    accept   ss-mp-fld-34
                    display  ss-mp-fld-34.
       entr-fld-35.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-35
                    accept   ss-mp-fld-35
                    display  ss-mp-fld-35.
       entr-fld-36.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-36
                    accept   ss-mp-fld-36
                    display  ss-mp-fld-36.
       entr-fld-37.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-37
                    accept   ss-mp-fld-37
                    display  ss-mp-fld-37.
       entr-fld-38.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-38
                    accept   ss-mp-fld-38
                    display  ss-mp-fld-38.
       entr-fld-39.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-39
                    accept   ss-mp-fld-39
                    display  ss-mp-fld-39.
       entr-fld-40.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-40
                    accept   ss-mp-fld-40
                    display  ss-mp-fld-40.
       entr-fld-41.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-41
                    accept   ss-mp-fld-41
                    display  ss-mp-fld-41.
       entr-fld-42.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-42
                    accept   ss-mp-fld-42
                    display  ss-mp-fld-42.
       entr-fld-43.
           if       kb-sngl-mult             =    "M"
                    display  ss-mp-fld-43
                    accept   ss-mp-fld-43
                    display  ss-mp-fld-43.
       entr-fld-44.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-44
                    accept   ss-mp-fld-44
                    display  ss-mp-fld-44.
       entr-fld-45.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-45
                    accept   ss-mp-fld-45
                    display  ss-mp-fld-45.
       entr-fld-46.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-46
                    accept   ss-mp-fld-46
                    display  ss-mp-fld-46.
       entr-fld-47.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-47
                    accept   ss-mp-fld-47
                    display  ss-mp-fld-47.
       entr-fld-48.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-48
                    accept   ss-mp-fld-48
                    display  ss-mp-fld-48.
       entr-fld-49.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-49
                    accept   ss-mp-fld-49
                    display  ss-mp-fld-49.
       entr-fld-50.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-50
                    accept   ss-mp-fld-50
                    display  ss-mp-fld-50.
       entr-fld-51.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-51
                    accept   ss-mp-fld-51
                    display  ss-mp-fld-51.
       entr-fld-52.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-52
                    accept   ss-mp-fld-52
                    display  ss-mp-fld-52.
       entr-fld-53.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-53
                    accept   ss-mp-fld-53
                    display  ss-mp-fld-53.
       entr-fld-54.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-54
                    accept   ss-mp-fld-54
                    display  ss-mp-fld-54.
       entr-fld-55.
           if       kb-sngl-mult             =      "M"
                    display  ss-mp-fld-55
                    accept   ss-mp-fld-55
                    display  ss-mp-fld-55.

       bck-fld.
           if       fld-no                   >      01
                    add  -02                 to     fld-no
           else
                    add  -01                 to     fld-no.

       vldt-fld.
           if       fld-no                   =      01
                    perform  vldt-fld-3.
           if       fld-no                   =      02
                    perform  vldt-fld-4.
           if       fld-no                   =      03
                    perform  vldt-fld-5.
           if       fld-no                   =      04
                    perform  vldt-fld-4.
           if       fld-no                   =      05
                    perform  vldt-fld-1.
           if       fld-no                   =      06
                    perform  vldt-fld-2.
           if       fld-no                   =      07
                    perform  vldt-fld-7.

           if       fld-no                   =      07
           and      run-mode                 =      "A"
                    perform  calc-dflt-fee.

           if       fld-no                   =      08
           and      ws-trnsf-tax-flg         =      "Y"
                    perform  vldt-fld-8.

           if       fld-no                   =      08
           and      run-mode                 =      "A"
                    perform  calc-trnsf-tax.

           if       fld-no                   =      14
                    perform  vldt-fld-14.
           if       fld-no                   =      17
                    perform  vldt-fld-17.
           if       fld-no                   =      20
                    perform  vldt-fld-20.
           if       fld-no                   =      23
                    perform  vldt-fld-23.
           if       fld-no                   =      26
                    perform  vldt-fld-26.
           if       fld-no                   =      29
                    perform  vldt-fld-29.
           if       fld-no                   =      32
                    perform  vldt-fld-32.
           if       fld-no                   =      35
                    perform  vldt-fld-35.
           if       fld-no                   =      38
                    perform  vldt-fld-38.
           if       fld-no                   =      41
                    perform  vldt-fld-41.
           if       fld-no                   =      44
                    perform  vldt-fld-44.
           if       fld-no                   =      47
                    perform  vldt-fld-47.
           if       fld-no                   =      50
                    perform  vldt-fld-50.
           if       fld-no                   =      53
                    perform  vldt-fld-53.

       vldt-fld-1.
           move     0004                     to      ic-cd-tp
           move     fr-rcd-ch                to      ic-id.
           move     lock-stts                to      file-stts.
           perform  read-ixcd-file
                    until    file-stts       not =   lock-stts.
           if       file-stts                =       "00"
                    move     ic-ch-lcn       to      edt-rcd-ch
                    display  ss-edt-1
           else
                    move     space           to      edt-rcd-ch
                    move     "1"             to      prog-lctn
                    perform  not-in-code-file
                    move     space           to      prog-lctn.
           perform  release-code-record.

       vldt-fld-2.
           if       fr-doc-tp                =       "MVLS"         *> force MVLS, MHLS fr-doc-tp to C fr-rcd-ch
           and      fr-rcd-ch                =       "I"
                    move     "2"             to      prog-lctn
                    perform  not-in-code-file
                    move     space           to      prog-lctn
           else
           if       fr-doc-tp                =       "MHLS"
           and      fr-rcd-ch                =       "I"
                    move     "2"             to      prog-lctn
                    perform  not-in-code-file
                    move     space           to      prog-lctn
           else
                    perform  vldt-fld-2-proc.

 vldt-fld-2-proc.
           move     0006                     to      ic-cd-tp.
           move     fr-doc-tp                to      ic-id.
           move     fr-rcd-ch                to      ic-doc-ch-lcn.

           move     lock-stts                to      file-stts.
           perform  read-ixcd-file
                    until file-stts          not =   lock-stts.

           if       file-stts                =       "00"
                    move     ic-doc-name     to      edt-doc-dsc
                    perform  load-rcd-bk-fee
                    display  ss-edt-2
           else
                    move     "2"             to      prog-lctn
                    perform  not-in-code-file
                    move     space           to      prog-lctn.

           if       ws-trnsf-tax-flg         not =   "Y"
                    move     zero            to      fr-valuation
                    move     zero            to      ws-valuation.
/
       vldt-fld-3.
           if       fr-name-tp1              =       space
                    move    "P"              to      fr-name-tp1.
           if       fr-name-tp1              =       "P"
                    move "Person           " to      edt-name-tp1
                    display  ss-edt-3
           else
           if       fr-name-tp1              =       "B"
                    move "Business         " to      edt-name-tp1
                    display  ss-edt-3
           else
                    move     "3"             to      prog-lctn
                    perform  not-in-code-file
                    move     space           to      prog-lctn.
           perform  release-code-record.

       vldt-fld-4.

       vldt-fld-5.
           if       fr-name-tp2              =     space
                    move "P"                 to    fr-name-tp2.

           if       fr-name-tp2              =     "P"
                    move "Person           " to    edt-name-tp2
                    display  ss-edt-5
           else
           if       fr-name-tp2              =     "B"
                    move "Business         " to    edt-name-tp2
                    display  ss-edt-5
           else
                    move     "5"             to    prog-lctn
                    perform  not-in-code-file
                    move     space           to    prog-lctn.
           perform  release-code-record.

       vldt-fld-7.
           if       fr-no-pages              <     01
                    perform  must-have-page-no.

       vldt-fld-8.
           if       fr-valuation             =     zero
                    move    space            to    nul-entry
                    display ss-no-valuation
                    accept  ss-no-valuation
                    display ss-erase-err.
/
       vldt-fld-14.
           if       ws-pay-tp1               not =  03
                    perform vldt-fld-14-proc
           else
           if       fr-doc-tp                =      "CO"
           or       fr-doc-tp                =      "COPIES"
           or       fr-doc-tp                =      "GA"
           or       fr-doc-tp                =      "KYLOT"
           or       fr-doc-tp                =      "PLAT"
           or       fr-doc-tp                =      "RELCSL"
           or       fr-doc-tp                =      "RELKYL"
           or       fr-doc-tp                =      "RELSTL"
           or       fr-doc-tp                =      "RELUNE"
           or       fr-doc-tp                =      "SAFE"
           or       fr-doc-tp                =      "SLIEN"
           or       fr-doc-tp                =      "SUPPORT"
           or       fr-doc-tp                =      "UNEMP"
           or       fr-doc-tp                =      "UNEMPL"
           or       fr-doc-tp                =      "WILL"
           or       fr-doc-tp                =      "WILLR"
                    perform  vldt-fld-14-proc
           else
                    add      -01             to     fld-no.

       vldt-fld-14-proc.
           move     ws-pay-tp1               to    ic-id.
           move     0009                     to    ic-cd-tp
           move     lock-stts                to    file-stts.

           perform  read-ixcd-file
                    until    file-stts       not =  lock-stts.

           if       file-stts                =      "00"
           and      kb-sngl-mult             =      "M"
                    move     ic-desc         to     edt-pay-tp1
                    display  ss-mp-edt-14
                    perform  exempt-ar-filter
           else
           if       file-stts                =      "00"
                    move     ic-desc         to     edt-pay-tp1
                    display  ss-edt-14
                    perform  exempt-ar-filter
           else
                    move     space           to     edt-pay-tp1
                    perform  dsply-vld-pay-tp.
           perform  release-code-record.

       vldt-fld-17.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp2               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until    file-stts       not = lock-stts.
           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp2
                    display  ss-mp-edt-17
                    perform  exempt-ar-filter
           else
           if       file-stts                =     "00"
                    move     ic-desc         to    edt-pay-tp2
                    display  ss-edt-17
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp2
                    perform  dsply-vld-pay-tp.
           perform  release-code-record.

       vldt-fld-20.
           move     0009                     to    ic-cd-tp.
           move     ws-pay-tp3               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.
           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp3
                    display  ss-mp-edt-20
                    perform  exempt-ar-filter
           else
           if       file-stts                =     "00"
                    move     ic-desc         to    edt-pay-tp3
                    display  ss-edt-20
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp3
                    perform  dsply-vld-pay-tp.
           perform  release-code-record.

       vldt-fld-23.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp4               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp4
                    display  ss-mp-edt-23
                    perform  exempt-ar-filter
           else
           if       file-stts                =     "00"
                    move     ic-desc         to    edt-pay-tp4
                    display  ss-edt-23
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp4
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-26.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp5               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp5
                    display  ss-mp-edt-26
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp5
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-29.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp6               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp6
                    display  ss-mp-edt-29
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp6
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-32.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp7               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp7
                    display  ss-mp-edt-32
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp7
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-35.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp8               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp8
                    display  ss-mp-edt-35
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp8
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-38.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp9               to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp9
                    display  ss-mp-edt-38
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp9
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-41.
           move     0009                     to    ic-cd-tp
           move     ws-pay-tp10              to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp10
                    display  ss-mp-edt-41
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp10
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-44.
           move     0009                     to    ic-cd-tp.
           move     ws-pay-tp11              to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp11
                    display  ss-mp-edt-44
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp11
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-47.
           move     0009                     to    ic-cd-tp.
           move     ws-pay-tp12              to    ic-id.
           move     lock-stts                to    file-stts.
           perform  read-ixcd-file
                    until file-stts          not = lock-stts.

           if       file-stts                =     "00"
           and      kb-sngl-mult             =     "M"
                    move     ic-desc         to    edt-pay-tp12
                    display  ss-mp-edt-47
                    perform  exempt-ar-filter
           else
                    move     space           to    edt-pay-tp12
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-50.
           move     0009                     to      ic-cd-tp.
           move     ws-pay-tp13              to      ic-id.
           move     lock-stts                to      file-stts.
           perform  read-ixcd-file
                    until file-stts          not =   lock-stts.

           if       file-stts                =       "00"
           and      kb-sngl-mult             =       "M"
                    move     ic-desc         to      edt-pay-tp13
                    display  ss-mp-edt-50
                    perform  exempt-ar-filter
           else
                    move     space           to      edt-pay-tp13
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.

       vldt-fld-53.
           move     0009                     to      ic-cd-tp.
           move     ws-pay-tp14              to      ic-id.
           move     lock-stts                to      file-stts.
           perform  read-ixcd-file
                    until file-stts          not =   lock-stts.

           if       file-stts                =       "00"
           and      kb-sngl-mult             =       "M"
                    move     ic-desc         to      edt-pay-tp14
                    display  ss-mp-edt-53
                    perform  exempt-ar-filter
           else
                    move     space           to      edt-pay-tp14
                    perform  dsply-vld-pay-tp.

           perform  release-code-record.
/
       exempt-ar-filter.
           if       ws-pay-tp1               =       "3"
           or       ws-pay-tp1               =       "4"
                    move     zero            to      ws-pay-amt1
                    move     zero            to      fr-amt-recd.

           if       ws-pay-tp1               =       "4"
                    perform verify-exempt.

           if       ws-pay-tp2               =       "4"
           or       ws-pay-tp3               =       "4"
           or       ws-pay-tp4               =       "4"
           or       ws-pay-tp2               =       "3"
           or       ws-pay-tp3               =       "3"
           or       ws-pay-tp4               =       "3"
                    perform  clear-fields.

           if       ws-pay-tp1               =       "4"
           or       ws-pay-tp1               =       "3"
                    move     60              to      fld-no
           else
           if       fr-amt-recd              not <   fr-amt-due
           and      kb-sngl-mult             not =   "M"
                    move     60              to      fld-no
           else
           if       fr-amt-recd              not <   ws-mult-amt-due
           and      kb-sngl-mult             =       "M"
                    move     60              to      fld-no.

       verify-exempt.
           move     space                    to      kb-exempt.
           display  "Exempt ?  "             line 16 position 35.
           accept   kb-exempt                line 16 position 00.
           if       kb-exempt                not =   "YES"
                    move " "                 to      ws-pay-tp1
                    move 13                  to      fld-no
           else
           if       kb-exempt                =       "YES"
                    move      zero           to      fr-rcd-fee
                    move      zero           to      fr-addl-pg-fee
                    move      zero           to      fr-pstg-fee
                    move      zero           to      fr-pnly-fee
                    move      zero           to      fr-addl-fee
                    move      zero           to      fr-afrd-hous
                    move      zero           to      fr-stat-fees
                    move      zero           to      fr-clrk-fees
                    move      zero           to      fr-amt-due
                    move      zero           to      fr-amt-recd
                    move      zero           to      ws-change
                    move      zero           to      fr-trnsf-tax.
           display  "                 "      line 16 position 35.

       clear-fields.
           if       kb-sngl-mult             =       "S"
                    perform  cler-pay-flds
                    move     14              to      fld-no
                    perform  entr-fld
                             until   fld-no  >       25
           else
           if       kb-sngl-mult             =       "M"
                    perform  mp-clear-pay-flds
                    display  ss-mp-amt-due
                    display  ss-mp-pay-flds
                    move     14              to      fld-no
                    perform  entr-fld
                             until   fld-no  >       55.
/
       must-have-page-no.
           add      -01                      to      fld-no.
           display  ss-must-have-page.
           accept   ss-must-have-page.
           display  ss-erase-err.

       not-in-code-file.
           add      -01                      to      fld-no.
           display  ss-not-in-code-file.
           accept   ss-not-in-code-file.
           display  ss-erase-err.

       dsply-vld-pay-tp.
           add      -01                      to      fld-no.
*          if                                        kenton
*          if       swch-nmbr(01)            =       "+"
                    display  ss-kenton-vld-pay-tp.
*          else
*                   display  ss-vld-pay-tp.
/
       load-lock-bk-pg.
           move     space                    to      find-flag.

*          display  fr-bk-to-rcd-in          at      2501.
*          display  fr-rcd-ch                at      2506.

           move     0007                     to      ic-cd-tp.
           move     fr-bk-to-rcd-in          to      ic-id.
           move     fr-rcd-ch                to      ic-bk-tp-ch-lcn.
           move     lock-stts                to      file-stts.
           perform  read-ixcd-file
                    until    file-stts       not =   lock-stts.

           if       file-stts                =       "00"
           and      ic-lst-pg-used           >       ic-max-pgs
           and      ic-locked                =       "LOCKED"
           and      sttn-nmbr                =       ic-locked-by
                    move     "LOCKED"        to      ic-locked
                    move     sttn-nmbr       to      ic-locked-by
                    move     02              to      file-nmbr
                    rewrite  index-code-record
                    perform  bmp-up-bk
                    perform  bmp-up-pg
                    move     "y"             to      find-flag
           else
           if       file-stts                =       "00"
           and      ic-lst-pg-used           <       ic-max-pgs
           and      ic-locked                =       "LOCKED"
           and      sttn-nmbr                =       ic-locked-by
                    move     "LOCKED"        to      ic-locked
                    move     sttn-nmbr       to      ic-locked-by
                    move     02              to      file-nmbr
                    rewrite  index-code-record
                    perform  bmp-up-pg
                    move     "y"             to      find-flag
           else
           if       file-stts                =       "00"
           and      ic-lst-pg-used           =       ic-max-pgs
           and      ic-locked                =       "LOCKED"
           and      sttn-nmbr                =       ic-locked-by
                    move     "LOCKED"        to      ic-locked
                    move     sttn-nmbr       to      ic-locked-by
                    move     02              to      file-nmbr
                    rewrite  index-code-record
                    perform  bmp-up-pg
                    move     "y"             to      find-flag
           else
           if       file-stts                =       "00"
           and      ic-lst-pg-used           <       ic-max-pgs
           and      ic-locked                not =   "LOCKED"
                    move     "LOCKED"        to      ic-locked
                    move     sttn-nmbr       to      ic-locked-by
                    move     02              to      file-nmbr
                    rewrite  index-code-record
                    perform  bmp-up-pg
                    move     "y"             to      find-flag
           else
           if       file-stts                =       "00"
           and      ic-lst-pg-used           >       ic-max-pgs
           and      ic-locked                not =   "LOCKED"
                    move     "LOCKED"        to      ic-locked
                    move     sttn-nmbr       to      ic-locked-by
                    move     02              to      file-nmbr
                    rewrite  index-code-record
                    perform  bmp-up-bk
                    perform  bmp-up-pg
                    move     "y"             to      find-flag
           else
           if       file-stts                =       "00"
           and      ic-lst-pg-used           =       ic-max-pgs
           and      ic-locked                not =   "LOCKED"
                    move     "LOCKED"        to      ic-locked
                    move     sttn-nmbr       to      ic-locked-by
                    move     02              to      file-nmbr
                    rewrite  index-code-record
                    perform  bmp-up-bk
                    perform  bmp-up-pg
                    move     "y"             to      find-flag
           else
           if       file-stts                =       "00"
           and      ic-locked                =       "LOCKED"
           and      ic-locked-by             not =   sttn-nmbr
                    add      -01             to      fld-no
                    display  ss-bk-in-use
                    accept   ss-bk-in-use
                    display  ss-erase-err
                    move     "y"             to      find-flag
           else
           if       file-stts                not =   "00"
                    move     "B"             to      prog-lctn
                    perform  not-in-code-file
                    move     space           to      prog-lctn
                    move     "y"             to      find-flag.

           if       find-flag                =       space
                    perform  load-lock-fail
                             until    find-flag
                                             >       space.

           perform  release-code-record.
/
       load-lock-fail.
           display  scrn-load-lock-fail.
           accept   scrn-load-lock-okay.
           display  ss-erase-err.

       bmp-up-pg.
           move     ic-lst-bk-used           to      fr-beg-bk.
           move     ic-lst-pg-used           to      fr-beg-pg.
           add      01                       to      fr-beg-pg.
           move     space                    to      fr-beg-sx.

           move     fr-beg-bk                to      fr-end-bk.
           move     fr-beg-pg                to      fr-end-pg.

           add      fr-no-pages              to      fr-end-pg.
           add      -01                      to      fr-end-pg.

           display  ss-edt-7.

       bmp-up-bk.
           display  ss-begin-bk.
           accept   ss-begin-bk.
           display  ss-erase-err.

           add      01                       to      ic-lst-bk-used.
           move     000000                   to      ic-lst-pg-used.
           display  ss-edt-7.
/
       load-rcd-bk-fee.
           move     ic-idx-cls               to      fr-doc-cls.
           move     ic-bk-to-rcd-in          to      fr-bk-to-rcd-in.
           move     ic-bkkp-cd               to      fr-bkkp-cd.
           move     ic-trnsf-tax-flg         to      ws-trnsf-tax-flg.
           move     ic-flat-rcd-fee          to      ws-rcd-fee.
           move     ic-addl-pg-fee           to      ws-addl-pg-fee.
           move     ic-pstg-fee              to      ws-pstg-fee.
           move     ic-pnly-fee              to      ws-pnly-fee.
           move     0.00                     to      ws-addl-fee.
           move     ic-trnsf-tax-fee         to      ws-trnsf-tax.
           move     ic-afrd-hous             to      ws-afrd-hous.
           move     ic-clk-fee               to      ws-clrk-fees.
           move     ic-state-fee             to      ws-stat-fees.

       calc-dflt-fee.
           if       fr-doc-tp                =       "COMBO"
           or       fr-doc-tp                =       "HUNT"
           or       fr-doc-tp                =       "FISH"
           or       fr-doc-tp                =       "FSHJT"
           or       fr-doc-tp                =       "HNTJR"
           or       fr-doc-tp                =       "HNTNR"
           or       fr-doc-tp                =       "HNT5"
           or       fr-doc-tp                =       "FSHNR"
           or       fr-doc-tp                =       "FSH3"
           or       fr-doc-tp                =       "FSH15"
           or       fr-doc-tp                =       "DEER"
           or       fr-doc-tp                =       "DEERJR"
           or       fr-doc-tp                =       "TURKEY"
           or       fr-doc-tp                =       "TROUT"
           or       fr-doc-tp                =       "DUCK"
           or       fr-doc-cls               =       "99"
                    perform calc-fish-fee
           else
                    perform cont-calc-dflt-fee.

       calc-fish-fee.
           move     zero                     to      fr-trnsf-tax.
           multiply fr-no-pages              by      ws-rcd-fee
                                             giving  fr-rcd-fee rounded.

           move     zero                     to      ws-addl-pg-amt.
           move     ws-addl-pg-amt           to      fr-addl-pg-fee.
           move     ws-pstg-fee              to      fr-pstg-fee.
           move     ws-pnly-fee              to      fr-pnly-fee.
           move     ws-addl-fee              to      fr-addl-fee.
           move     ws-afrd-hous             to      fr-afrd-hous.
           move     ws-clrk-fees             to      fr-clrk-fees.
           move     ws-stat-fees             to      fr-stat-fees.

       cont-calc-dflt-fee.
           move     ws-rcd-fee               to      fr-rcd-fee.

           if       fr-no-pages              >       03
                    move  fr-no-pages        to      ws-no-pages
                    add   -03                to      ws-no-pages
                    multiply ws-no-pages     by      ws-addl-pg-fee
                                             giving  ws-addl-pg-amt rounded
           else
                    move     zero            to      ws-addl-pg-amt.

           move     ws-addl-pg-amt           to      fr-addl-pg-fee.

           move     ws-pstg-fee              to      fr-pstg-fee.

           if       run-mode                 =       "A"
                    move     ws-pnly-fee     to      fr-pnly-fee
                    move     ws-addl-fee     to      fr-addl-fee.
           move     ws-afrd-hous             to      fr-afrd-hous.
           move     ws-stat-fees             to      fr-stat-fees.
           move     ws-clrk-fees             to      fr-clrk-fees.

           perform  calc-trnsf-tax.
/
       calc-trnsf-tax.
           move     zero                     to     fr-trnsf-tax.
           if       ws-val-1                 >      zero
                    divide   ws-val-1        by     01
                                             giving fr-trnsf-tax
           else
                    move     zero            to     fr-trnsf-tax.

           if       ws-val-2                 >      000
           and      ws-val-2                 <      501
                    add      .50             to     fr-trnsf-tax
           else
           if       ws-val-2                 >      500
           and      ws-val-2                 <      1000
                    add      1.00            to     fr-trnsf-tax.

       calc-amt-due.
           add      fr-rcd-fee
                    fr-addl-pg-fee
                    fr-pstg-fee
                    fr-pnly-fee
                    fr-addl-fee
                    fr-trnsf-tax             giving  fr-amt-due.

       calc-sngl-payment.
           move     zero                     to      ws-change.

           add      ws-pay-amt1
                    ws-pay-amt2
                    ws-pay-amt3
                    ws-pay-amt4
                    ws-pay-amt5
                    ws-pay-amt6
                    ws-pay-amt7
                    ws-pay-amt8
                    ws-pay-amt9
                    ws-pay-amt10
                    ws-pay-amt11
                    ws-pay-amt12
                    ws-pay-amt13
                    ws-pay-amt14              giving  fr-amt-recd.

           if       kb-sngl-mult              =      "M"
                    subtract ws-mult-amt-due  from
                             fr-amt-recd      giving ws-change
           else
           if       kb-sngl-mult              not =  "M"
                    subtract fr-amt-due       from
                             fr-amt-recd      giving ws-change.

           if       ws-change                 not <  zero
                    move     "Refund Due "    to     ws-chng-or-due-titl
           else
                    move     "Balance Due"    to     ws-chng-or-due-titl.

           if       ws-change                 >      0
                    perform change-filtr.

       calc-mult-payment.
           move     zero                      to     ws-change.
           add      ws-pay-amt1
                    ws-pay-amt2
                    ws-pay-amt3
                    ws-pay-amt4
                    ws-pay-amt5
                    ws-pay-amt6
                    ws-pay-amt7
                    ws-pay-amt8
                    ws-pay-amt9
                    ws-pay-amt10
                    ws-pay-amt11
                    ws-pay-amt12
                    ws-pay-amt13
                    ws-pay-amt14              giving ws-amt-recd.

           if       ws-amt-recd               >      ws-mult-amt-due
                    subtract ws-mult-amt-due  from
                             ws-amt-recd      giving ws-change
           else
                    move     zero             to     ws-change.

           if       ws-change                 >      0
                    perform  mp-change-filtr.

           if       ws-change                 >      zero
                    move     "Refund Due "    to     ws-chng-or-due-titl
           else
                    subtract ws-amt-recd      from   ws-mult-amt-due
                                              giving ws-change
                    move     "Balance Due"    to     ws-chng-or-due-titl.

           display  ss-mp-amt-due.
           display  ss-mp-chng-rvrs.
/
       mp-change-filtr.
           if       ws-pay-tp1           =      "2"
           or       ws-pay-tp2           =      "2"
           or       ws-pay-tp3           =      "2"
           or       ws-pay-tp4           =      "2"
           or       ws-pay-tp5           =      "2"
           or       ws-pay-tp6           =      "2"
           or       ws-pay-tp7           =      "2"
           or       ws-pay-tp8           =      "2"
           or       ws-pay-tp9           =      "2"
           or       ws-pay-tp10          =      "2"
           or       ws-pay-tp11          =      "2"
           or       ws-pay-tp12          =      "2"
           or       ws-pay-tp13          =      "2"
           or       ws-pay-tp14          =      "2"
                    display ss-no-change
                    accept  ss-no-change
                    display ss-erase-err
                    move    27           to     fld-no
           else
           if       ws-change            >      50.00
           and      fld-no               >      17
                    display ss-chng-ovr-50
                    accept  ss-chng-ovr-50
                    display ss-erase-err.
*                   move    27           to     fld-no.

       change-filtr.
           if       ws-pay-tp1               =      "2"
           or       ws-pay-tp2               =      "2"
           or       ws-pay-tp3               =      "2"
           or       ws-pay-tp4               =      "2"
                    display ss-no-change
                    accept  ss-no-change
                    display ss-erase-err
                    move    13               to     fld-no
           else
           if       ws-change                >       50.00
           and      fld-no                   >       17
                    display ss-chng-ovr-50
                    accept  ss-chng-ovr-50
                    display ss-erase-err.
*                   move    27               to     fld-no.
/
       *>----  for cov lien counter and indep user Peggy Rose print receipts
       *>----  else turn receipt printing off

       print-receipt-swch.
           if       lasr-rcpt-sttn	     =      "y"
                    perform  prnt-rcpt-lasr.
           
                                                       
       prnt-rcpt-prtr-itca-zzzz.                                
           open     output  itca-file.
           inspect  detl-itca-line
                    replacing characters     by     "-".
           perform  prnt-itca.
                                                                                       
           move     "RECEIPT       "         to    detl-itca-titl.
           move     edt-clctn-ch             to    detl-itca-desc.
           perform  prnt-itca             02    times.

           move     ws-offc-name             to    detl-itca-line.
           perform  prnt-itca.
           move     ws-offcl-name            to    detl-itca-line.            
           perform  prnt-itca             02    times.

           perform  release-code-record.
                                                                        
           string   fr-name1  delimited      by    " "
                    " / "     delimited      by    size
                    fr-name2  delimited      by    "  "
                                             into  detl-itca-line.
           perform  prnt-itca.

           move     "Document No  :"         to    detl-itca-titl.             
           move     fr-doc-no                to    edt-doc-no.               
           move     edt-doc-no               to    detl-itca-desc.
           perform  prnt-itca.

           move     "Document Type:"         to    detl-itca-titl.
           move     edt-doc-dsc              to    detl-itca-desc.
           perform  prnt-itca.

           string   "Date Recorded:  "
                    delimited                by    size
                    edt-date
                    delimited                by    size
                    "   "                                                  
                    delimited                by    size
                    edt-time
                    delimited                by    size
                                             into  detl-itca-line.
           perform  prnt-itca.
          
           if       fr-doc-cls               =     20
                    move  "File Number  :"   to    detl-itca-titl
		    perform prnt-trim-file-nmbr
           else
           if       fr-doc-cls               =      99
           and      fr-bk-to-rcd-in          =      99
                    next sentence
           else                                                    
                    perform  prnt-bkpg-itca.

           move     "Courthouse   :"         to    detl-itca-titl.
           move     edt-rcd-ch               to    detl-itca-desc.
           perform  prnt-itca.

           move     "Recording Fee:"         to    detl-itca-titl.
           move     fr-rcd-fee               to    edt-amount.
           move     edt-amount               to    detl-itca-desc.
           perform  prnt-itca.

           if       fr-afrd-hous             >     zero
                    move    "Housing trust:" to    detl-itca-titl
                    move    fr-afrd-hous     to    edt-amount
                    move    edt-amount       to    detl-itca-desc
                    perform prnt-itca.

           if       fr-addl-pg-fee           >     zero
                    move    "Addl Page Fee:" to    detl-itca-titl
                    move    fr-addl-pg-fee   to    edt-amount
                    move    edt-amount       to    detl-itca-desc
                    perform prnt-itca.

           if       fr-pstg-fee              >     zero
                    move    "Postage Fee  :" to    detl-itca-titl
                    move    fr-pstg-fee      to    edt-amount
                    move    edt-amount       to    detl-itca-desc
                    perform prnt-itca.

           if       fr-trnsf-tax             >     zero
                    move    "Transfer Tax :" to    detl-itca-titl
                    move    fr-trnsf-tax     to    edt-amount
                    move    edt-amount       to    detl-itca-desc
                    perform prnt-itca.

           if       fr-addl-fee              >     zero
                    move    "Addtnl Fee  :"  to    detl-itca-titl                        
                    move    fr-addl-fee      to    edt-amount
                    move    edt-amount       to    detl-itca-desc
                    perform prnt-itca.

           if       fr-pnly-fee              >     zero
                    move    "Penalty Fee  :" to    detl-itca-titl
                    move    fr-pnly-fee      to    edt-amount
                    move    edt-amount       to    detl-itca-desc
                    perform prnt-itca.
                                                                          
           move     "Amt Due:"               to    detl-itca-titl.
           move     fr-amt-due               to    edt-amount.
           move     edt-amount               to    detl-itca-desc.
           perform  prnt-itca.

           if       fr-sngl-mult             not = "M"
                    move     "Amt Received :"                                             
                                             to    detl-itca-titl
                    move     fr-amt-recd     to    edt-amount
                    move     edt-amount      to    detl-itca-desc
                    perform  prnt-itca.

           perform  print-pay-types-itca.
           close    itca-file.
      

       prnt-rcpt-lasr.
           perform  print-receipt-hedr.
           perform  release-code-record.
           string   fr-name1  delimited      by    " "
                    " / "     delimited      by    size
                    fr-name2  delimited      by    "  "             
                                             into  dt-title.
           perform  print-detail.

           move     "Document Number    :"   to    dt-title.             
           move     fr-doc-no                to    edt-doc-no.
           move     edt-doc-no               to    dt-desc.
           perform  print-detail.

           move     "Document Type      :"   to    dt-title.
           move     edt-doc-dsc              to    dt-desc.
           perform  print-detail.

           move     "Date Recorded      :"   to    dt-title.
           move     space                    to    dt-desc.
           string   edt-date
                    delimited                by    size
                    "   "
                    delimited                by    size
                    edt-time
                    delimited                by    size
                                             into  dt-desc.
           perform  print-detail.
          
           if       fr-doc-cls               =      20              
                    move  "File Number        :"   
                    			     to     dt-title
		    perform prnt-trim-file-nmbr
           else
           if       fr-doc-cls               =      99
           and      fr-bk-to-rcd-in          =      99
                    next sentence
           else
                    perform  prnt-bkpg-lasr.

           move     "Courthouse         :"   to    dt-title.
           move     edt-rcd-ch               to    dt-desc.
           perform  print-detail.

           move     "Recording Fee      :"   to    dt-title.
           move     fr-rcd-fee               to    edt-amount.
           move     edt-amount               to    dt-desc.
           perform  print-detail.

           if       fr-afrd-hous             >     zero
                    move    "Housing trust      :" 
                    			     to    dt-title
                    move    fr-afrd-hous     to    edt-amount
                    move    edt-amount       to    dt-desc
                    perform print-detail.

           if       fr-addl-pg-fee           >     zero
                    move    "Additional Page Fee:" 
                    			     to    dt-title
                    move    fr-addl-pg-fee   to    edt-amount
                    move    edt-amount       to    dt-desc
                    perform print-detail.

           if       fr-pstg-fee              >     zero
                    move    "Postage Fee        :" 
                    			     to    dt-title
                    move    fr-pstg-fee      to    edt-amount
                    move    edt-amount       to    dt-desc              
                    perform print-detail.

           if       fr-trnsf-tax             >     zero
                    move    "Transfer Tax 	:" 
                    			     to    dt-title
                    move    fr-trnsf-tax     to    edt-amount
                    move    edt-amount       to    dt-desc
                    perform print-detail.

           if       fr-addl-fee              >     zero
                    move    "Additional Fee     :"  
                    			     to    dt-title                              
                    move    fr-addl-fee      to    edt-amount
                    move    edt-amount       to    dt-desc
                    perform print-detail.

           if       fr-pnly-fee              >     zero
                    move    "Penalty Fee        :" 
                    			     to    dt-title
                    move    fr-pnly-fee      to    edt-amount
                    move    edt-amount       to    dt-desc
                    perform print-detail.

           move     "Amount Due         :"   to    dt-title.
           move     fr-amt-due               to    edt-amount.
           move     edt-amount               to    dt-desc.
           perform  print-detail.

           if       fr-sngl-mult               not = "M"
                    move     "Amount Received    :"                                             
                                               to    dt-title
                    move     fr-amt-recd       to    edt-amount
                    move     edt-amount        to    dt-desc
                    perform  print-detail.

           perform  print-pay-types.
           close    print-file.
                                                                          
/
       print-mult-payoff-receipt-swch.
           if       dymo-flag                  =     "y"
                    perform  print-mult-payoff-receipt-lasr
           else
                    perform  print-mult-payoff-receipt-itca.

       print-mult-payoff-receipt-itca.
           open     output  itca-file.

           if       kb-sngl-mult               =     "M"
           and      fr-amt-recd                >     zero
                    perform  prnt-itca
                    move     "---------- Multi Doc Payment -----------"
                                               to    detl-itca-line
                    perform  prnt-itca
                    move     "Total Amt Due:"  to    detl-itca-titl
                    move     ws-mult-amt-due   to    edt-amount
                    move     space             to    detl-itca-desc
                    string   edt-amount              delimited by size
                             "  ["                   delimited by size
                             ws-mult-doc-cnt         delimited by size
                             "]"                     delimited by size
                             		        into  detl-itca-desc
                    perform  prnt-itca
                    move     "Amt Received :"
                                               to    detl-itca-titl
                    move     ws-mp-amt-recd    to    edt-amount
                    move     edt-amount        to    detl-itca-desc
                    perform  prnt-itca.
           perform  print-pay-types-itca.
           perform  prnt-itca               07    times.
           close    itca-file.
/
       print-mult-payoff-receipt-lasr.
           perform  print-receipt-hedr.                

           if       kb-sngl-mult               =     "M"
           and      ws-amt-recd                >     zero
                    perform  prnt-mult-pyof-hedr
                    perform  prnt-mult-pyof-detl
                    perform  prnt-mult-pyof-fotr.
           perform  print-pay-types.

           perform  print-detail.
           close    print-file.

       prnt-mult-pyof-hedr.
           perform  print-detail
           move     "Document Number     Type       Amount Due"
                                               to    dt-line.
           perform  print-detail.

       prnt-mult-pyof-detl.
           move     03                         to    file-nmbr.
           close    multi-tmp.
           open     input multi-tmp.

           move     space                      to    file-stts.
           move     01                         to    line-nmbr.
           perform  prnt-mult-pyof-detl-inpt
                    until    file-stts         =     "10".

       prnt-mult-pyof-detl-inpt.
           move     03                         to    file-nmbr.
           read     multi-tmp
                    next
                    at       end
                             move      "10"    to    file-stts.
           if       file-stts                  =     "00"
                    perform  prnt-mult-pyof-detl-amnt.

       prnt-mult-pyof-detl-amnt.
           if       ws-mult-doc-cnt            >     55
                    perform  print-receipt-hedr
                    perform  prnt-mult-pyof-hedr
                    move     16                to    line-nmbr.

           move     mt-doc-no                  to    dt-dcmt-nmbr.
           move     mt-doc-tp                  to    dt-dcmt-type.
           move     mt-amt-due                 to    dt-amnt-due.
           perform  print-detail.

           add      01                         to    line-nmbr.

       prnt-mult-pyof-fotr.
           move     space                      to    dt-prnt.
           perform  print-detail.
           move     "Total Amount Due   :"
                                               to    dt-title. 
           move     ws-mult-amt-due            to    edt-amount.
           move     space                      to    dt-desc.
           string   edt-amount                 delimited by size
                    "  ["                      delimited by size
                    ws-mult-doc-cnt            delimited by size
                    "]"			       delimited by size
                    			       into  dt-desc.
           perform  print-detail.
           move     "Amount Received    :"     to    dt-title.
           move     ws-amt-recd                to    edt-amount.
           move     edt-amount                 to    dt-desc.
           perform  print-detail.                        
                                                                            
       print-receipt-hedr.
           move     prtr-name		     to    prnt-path.
           open     output  print-file.
           move     dflt-sqnc                to    print-record.
           write    print-record             after zero.
           move     font-sqnc                to    print-record.           
           write    print-record             after zero.
           move     spac-sqnc                to    print-record.
           write    print-record             after zero.
           move     space		     to	   dt-prnt.
           perform  print-detail	     02    times.
                                                                             
           move     09                       to    font-ptch.
           move     font-sqnc		     to	   print-record.       
           write    print-record	     after zero.
                                                                                 
           move     "RECEIPT"                to    dt-prnt.
           move     edt-clctn-ch             to    dt-desc.
           perform  print-detail             02    times.

           move     ws-offc-name             to    dt-prnt.
           perform  print-detail.
           move     ws-offcl-name            to    dt-prnt.
           perform  print-detail.                                              
           	   
           move     "PO BOX 1109"	     to	   dt-prnt.
           perform  print-detail.
           move     "COVINGTON  KY  41012-1109"
           				     to	   dt-prnt.       
           perform  print-detail             02    times.
  
       print-pay-types.             
           perform  print-detail.
           if       ws-amt-recd                 =      zero       
           and      fr-sngl-mult                =      "M"
           and      kb-payoff                   not =  "Y"
                    move     "MULTI PAY"        to         dt-desc
                    move     "Payment Type       :"   
                    				to         dt-title
                    perform  print-detail
           else
           if       ws-pay-amt1                 >      zero
                    move     "Payment Type 	 :"   
                    				to         dt-title
                    move     ws-pay-amt1        to         edt-amount
                    string   edt-amount         delimited  by    size
                             "   "              delimited  by    size
                             edt-pay-tp1        delimited  by    size
                                                into       dt-desc
                    perform  print-detail.

           if       ws-chk-no1                  >     space
                    move     "Check/Card#  	 :"   
                    				to         dt-title
                    move     ws-chk-no1         to         dt-desc
                    perform  print-detail.

           if       ws-pay-amt2                 >     zero
                    move     ws-pay-amt2        to    edt-amount
                    move     "Payment Type       :"   
                    				to    dt-title
                    string   edt-amount         delimited  by   size
                             "   "              delimited  by   size
                             edt-pay-tp2        delimited  by   size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no2                  >     space
                    move     "Check/Card#        :"   
                    				to    dt-title
                    move     ws-chk-no2         to    dt-desc
                    perform  print-detail.

           if       ws-pay-amt3                 >     zero
                    move     ws-pay-amt3        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    dt-title
                    string   edt-amount         delimited  by    size
                             "   "              delimited  by    size
                             edt-pay-tp3        delimited  by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no3                  >   space
                    move     "Check/Card#  	 :"   
                    				to  dt-title
                    move     ws-chk-no3         to  dt-desc
                    perform  print-detail.

           if       ws-pay-amt4                 >   zero
                    move     ws-pay-amt4        to  edt-amount
                    move     "Payment Type 	 :"   
                    				to  dt-title
                    string   edt-amount         delimited  by    size
                             "   "              delimited  by    size
                             edt-pay-tp4        delimited  by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no4                  >     space
                    move     "Check/Card#  	 :"   
                    				to    dt-title
                    move     ws-chk-no4         to    dt-desc
                    perform  print-detail.

           if       ws-pay-amt5                 >     zero
                    move     ws-pay-amt5        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    dt-title
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp5
                             delimited          by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no5                  >     space
                    move     "Check/Card#  	 :"   
                    				to    dt-title
                    move     ws-chk-no5         to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt6                 >     zero
                    move     ws-pay-amt6        to    edt-amount
                    move     "Payment Type	 :"   
                    				to    dt-title
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp6
                             delimited          by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no6                  >     space
                    move     "Check/Card#        :"   
                    				to    dt-title
                    move     ws-chk-no6         to    dt-desc
                    perform  print-detail.

           if       ws-pay-amt7                 >     zero
                    move     ws-pay-amt7        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    dt-title
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp7
                             delimited          by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no7                  >     space
                    move     "Check/Card#  	 :"   
                    				to    dt-title
                    move     ws-chk-no7         to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt8                 >     zero
                    move     ws-pay-amt8        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    dt-title
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp8
                             delimited          by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no8                  >     space
                    move     "Check/Card#  	 :"   
                    				to    dt-title
                    move     ws-chk-no8         to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt9                 >     zero
                    move     ws-pay-amt9        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    dt-title
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp9
                             delimited          by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no9                  >     space
                    move     "Check/Card#  	 :"  
                    				to    dt-title
                    move     ws-chk-no9         to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt10                >     zero
                    move     ws-pay-amt10       to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    dt-title
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp10
                             delimited          by    size
                                                into  dt-desc
                    perform  print-detail.

           if       ws-chk-no10                 >     space
                    move     "Check/Card#  	 :"   
                    				to    dt-title
                    move     ws-chk-no10        to    dt-desc
                    perform  print-detail.

           if       ws-pay-amt11               >   zero
                    move     ws-pay-amt11      to  edt-amount
                    move     "Payment Type 	 :"  
                    			       to  dt-title
                    string   edt-amount        delimited  by    size
                             "   "             delimited  by    size
                             edt-pay-tp11      delimited  by    size
                                               into  dt-desc
                    perform  print-detail.

           if       ws-chk-no11                >     space
                    move     "Check/Card#        :"
                    			       to    dt-title
                    move     ws-chk-no11       to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt12               >     zero
                    move     ws-pay-amt12      to    edt-amount
                    move     "Payment Type       :"
                    			       to    dt-title
                    string   edt-amount
                             delimited         by    size
                             "   "
                             delimited         by    size
                             edt-pay-tp12
                             delimited         by    size
                                               into  dt-desc
                    perform  print-detail.

           if       ws-chk-no12                >     space
                    move     "Check/Card#        :"
                                               to    dt-title
                    move     ws-chk-no12       to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt13               >     zero
                    move     ws-pay-amt13      to    edt-amount
                    move     "Payment Type       :"
                    			       to    dt-title
                    string   edt-amount
                             delimited         by    size
                             "   "
                             delimited         by    size
                             edt-pay-tp13
                             delimited         by    size
                                               into  dt-desc
                    perform  print-detail.

           if       ws-chk-no13                >     space
                    move     "Check/Card#        :"
                    			       to    dt-title
                    move     ws-chk-no13       to    dt-desc
                    perform  print-detail.


           if       ws-pay-amt14               >     zero
                    move     ws-pay-amt14      to    edt-amount
                    move     "Payment Type       :"
                    			       to    dt-title
                    string   edt-amount                             
                             delimited         by    size
                             "   "
                             delimited         by    size
                             edt-pay-tp14
                             delimited         by    size
                                               into  dt-desc
                    perform  print-detail.

           if       ws-chk-no14                >     space
                    move     "Check/Card#        :"
                    			       to    dt-title
                    move     ws-chk-no14       to    dt-desc
                    perform  print-detail.


           if       ws-pay-tp1                 =     "3"
                    move     zero              to    ws-change
                    move     "A/R"             to    dt-desc
                    perform  print-detail.

           if       ws-change                  not = zero
           and      fr-sngl-mult               not = "M"
                    perform  print-detail
                    move     "Change given       :"
                    			       to    dt-title
                    move     ws-change         to    edt-amount
                    move     edt-amount        to    dt-desc
                    perform  print-detail.

           move     "Clerk name         :"     to    dt-title.
           move     edt-clrk-name              to    dt-desc.
           perform  print-detail.
           inspect  dt-line
                    replacing characters       by    "-".
           perform  print-detail.
           
      print-pay-types-itca.             
           perform  prnt-itca.
           if       ws-amt-recd                 =      zero       
           and      fr-sngl-mult                =      "M"
           and      kb-payoff                   not =  "Y"
                    move     "MULTI PAY"        to         detl-itca-desc
                    move     "Payment Type       :"   
                    				to         detl-itca-titl
                    perform  prnt-itca
           else
           if       ws-pay-amt1                 >      zero
                    move     "Payment Type 	 :"   
                    				to         detl-itca-titl
                    move     ws-pay-amt1        to         edt-amount
                    string   edt-amount         delimited  by    size
                             "   "              delimited  by    size
                             edt-pay-tp1        delimited  by    size
                                                into       detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no1                  >     space
                    move     "Check/Card#  	 :"   
                    				to         detl-itca-titl
                    move     ws-chk-no1         to         detl-itca-desc
                    perform  prnt-itca.

           if       ws-pay-amt2                 >     zero
                    move     ws-pay-amt2        to    edt-amount
                    move     "Payment Type       :"   
                    				to    detl-itca-titl
                    string   edt-amount         delimited  by   size
                             "   "              delimited  by   size
                             edt-pay-tp2        delimited  by   size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no2                  >     space
                    move     "Check/Card#        :"   
                    				to    detl-itca-titl
                    move     ws-chk-no2         to    detl-itca-desc
                    perform  prnt-itca.

           if       ws-pay-amt3                 >     zero
                    move     ws-pay-amt3        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    detl-itca-titl
                    string   edt-amount         delimited  by    size
                             "   "              delimited  by    size
                             edt-pay-tp3        delimited  by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no3                  >   space
                    move     "Check/Card#  	 :"   
                    				to  detl-itca-titl
                    move     ws-chk-no3         to  detl-itca-desc
                    perform  prnt-itca.

           if       ws-pay-amt4                 >   zero
                    move     ws-pay-amt4        to  edt-amount
                    move     "Payment Type 	 :"   
                    				to  detl-itca-titl
                    string   edt-amount         delimited  by    size
                             "   "              delimited  by    size
                             edt-pay-tp4        delimited  by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no4                  >     space
                    move     "Check/Card#  	 :"   
                    				to    detl-itca-titl
                    move     ws-chk-no4         to    detl-itca-desc
                    perform  prnt-itca.

           if       ws-pay-amt5                 >     zero
                    move     ws-pay-amt5        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    detl-itca-titl
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp5
                             delimited          by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no5                  >     space
                    move     "Check/Card#  	 :"   
                    				to    detl-itca-titl
                    move     ws-chk-no5         to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt6                 >     zero
                    move     ws-pay-amt6        to    edt-amount
                    move     "Payment Type	 :"   
                    				to    detl-itca-titl
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp6
                             delimited          by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no6                  >     space
                    move     "Check/Card#        :"   
                    				to    detl-itca-titl
                    move     ws-chk-no6         to    detl-itca-desc
                    perform  prnt-itca.

           if       ws-pay-amt7                 >     zero
                    move     ws-pay-amt7        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    detl-itca-titl
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp7
                             delimited          by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no7                  >     space
                    move     "Check/Card#  	 :"   
                    				to    detl-itca-titl
                    move     ws-chk-no7         to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt8                 >     zero
                    move     ws-pay-amt8        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    detl-itca-titl
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp8
                             delimited          by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no8                  >     space
                    move     "Check/Card#  	 :"   
                    				to    detl-itca-titl
                    move     ws-chk-no8         to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt9                 >     zero
                    move     ws-pay-amt9        to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    detl-itca-titl
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp9
                             delimited          by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no9                  >     space
                    move     "Check/Card#  	 :"  
                    				to    detl-itca-titl
                    move     ws-chk-no9         to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt10                >     zero
                    move     ws-pay-amt10       to    edt-amount
                    move     "Payment Type 	 :"   
                    				to    detl-itca-titl
                    string   edt-amount
                             delimited          by    size
                             "   "
                             delimited          by    size
                             edt-pay-tp10
                             delimited          by    size
                                                into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no10                 >     space
                    move     "Check/Card#  	 :"   
                    				to    detl-itca-titl
                    move     ws-chk-no10        to    detl-itca-desc
                    perform  prnt-itca.

           if       ws-pay-amt11               >   zero
                    move     ws-pay-amt11      to  edt-amount
                    move     "Payment Type 	 :"  
                    			       to  detl-itca-titl
                    string   edt-amount        delimited  by    size
                             "   "             delimited  by    size
                             edt-pay-tp11      delimited  by    size
                                               into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no11                >     space
                    move     "Check/Card#        :"
                    			       to    detl-itca-titl
                    move     ws-chk-no11       to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt12               >     zero
                    move     ws-pay-amt12      to    edt-amount
                    move     "Payment Type       :"
                    			       to    detl-itca-titl
                    string   edt-amount
                             delimited         by    size
                             "   "
                             delimited         by    size
                             edt-pay-tp12
                             delimited         by    size
                                               into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no12                >     space
                    move     "Check/Card#        :"
                                               to    detl-itca-titl
                    move     ws-chk-no12       to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt13               >     zero
                    move     ws-pay-amt13      to    edt-amount
                    move     "Payment Type       :"
                    			       to    detl-itca-titl
                    string   edt-amount
                             delimited         by    size
                             "   "
                             delimited         by    size
                             edt-pay-tp13
                             delimited         by    size
                                               into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no13                >     space
                    move     "Check/Card#        :"
                    			       to    detl-itca-titl
                    move     ws-chk-no13       to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-amt14               >     zero
                    move     ws-pay-amt14      to    edt-amount
                    move     "Payment Type       :"
                    			       to    detl-itca-titl
                    string   edt-amount                             
                             delimited         by    size
                             "   "
                             delimited         by    size
                             edt-pay-tp14
                             delimited         by    size
                                               into  detl-itca-desc
                    perform  prnt-itca.

           if       ws-chk-no14                >     space
                    move     "Check/Card#        :"
                    			       to    detl-itca-titl
                    move     ws-chk-no14       to    detl-itca-desc
                    perform  prnt-itca.


           if       ws-pay-tp1                 =     "3"
                    move     zero              to    ws-change
                    move     "A/R"             to    detl-itca-desc
                    perform  prnt-itca.

           if       ws-change                  not = zero
           and      fr-sngl-mult               not = "M"
                    perform  prnt-itca
                    move     "Change given       :"
                    			       to    detl-itca-titl
                    move     ws-change         to    edt-amount
                    move     edt-amount        to    detl-itca-desc
                    perform  prnt-itca.

           move     "Clerk name         :"     to    detl-itca-titl.
           move     edt-clrk-name              to    detl-itca-desc.
           perform  prnt-itca.
           inspect  dt-line
                    replacing characters       by    "-".
           perform  prnt-itca.
           
/
   
       entr-kb-vldt.
           move     space                    	to    kb-validate.
           display  ss-vldt-another.         	
           accept   ss-vldt-another.         	
           display  ss-erase-err.            	
           if       kb-validate              	=     space
           or       crt-s2			=     zero
                    move     "N"             	to    kb-validate.
           if       kb-validate              	=     "Y"
                    perform  print-validation-swch.
                    
       print-validation-swch.                                        
           if       dymo-flag                	=     "y"                                 
                    perform   prnt-vldt-dymo
           else                                                 
                    perform   prnt-vldt-itca.       
           move     space			to    kb-validate.                    

       prnt-vldt-dymo.  *> use the dymo printer
           call     "dymo010.dll"            	using fr-doc-no.
           cancel   "dymo010.dll".
                                           

       prnt-vldt-itca.  *> use the ithaca printer
           open     output itca-file.       	                         
           write    itca-rcrd             	from "&%VO".
           close    itca-file.              	
                                             	
           move     space                    	to    nul-entry.
           display  ss-vldt-doc.             	
           accept   ss-vldt-doc.             	                      
           display  ss-erase-err.            	
                                             	
           open     output   itca-file.
           write    itca-rcrd             	from "&%VC".
                                             	
           perform  prnt-itca             	06    times.
           move     "Recorded:"               	to    detl-itca-titl.
           move     ws-offcl-name            	to    detl-itca-desc.
           perform  prnt-itca.            	
           move     ws-offc-name             	to    detl-itca-desc.
           move     edt-rcd-ch               	to    detl-itca-titl.
           perform  prnt-itca.            	
           move     "Doc type:"              	to    detl-itca-titl
           move     edt-doc-dsc              	to    detl-itca-desc.
           perform  prnt-itca.            	
           if       fr-doc-cls               	=     20
                    move   "File No:"        	to    detl-itca-titl
                    perform prnt-trim-file-nmbr
           else
           if       fr-doc-cls               =     99
                    next sentence
           else                                                 
                    perform  prnt-bkpg-itca.                              

           move     "Doc#:"                  to    detl-itca-titl.
           move     fr-doc-no                to    edt-doc-no.
           move     edt-doc-no               to    detl-itca-desc.
           perform  prnt-itca.

           move     "Dt/tm Recorded:"        to    detl-itca-titl.
           string   edt-date       delimited by    size
                    "   "          delimited by    size
                    edt-time       delimited by    size
                                             into  detl-itca-desc.
           perform  prnt-itca.

           move     fr-amt-due               to    edt-amount.
           move     fr-trnsf-tax             to    edt-ttax.
           string   "Total fees: " delimited by    size
                    edt-amount     delimited by    size          
                    "  "           delimited by    size
                    "Tax:"         delimited by    size
                    edt-ttax       delimited by    size
                                             into  detl-itca-line.
           perform  prnt-itca.

           move     "Clerk name:"            to    detl-itca-titl.
           move     edt-clrk-name            to    detl-itca-desc.

           perform  prnt-itca                04    times.
           close    itca-file.

       prnt-bkpg-itca.
           move     "Book/Page :"	       to    detl-itca-titl.
           perform  prnt-bkpg-proc.
           perform  prnt-bkpg-itca-desc.
           perform  prnt-itca.
         
       prnt-bkpg-lasr.
           move     "Book / Page        :"     to    dt-title.
           perform  prnt-bkpg-proc.
           perform  prnt-bkpg-lasr-desc.
           perform  print-detail.
           
       prnt-bkpg-proc.           
           move     fr-beg-bk                  to    edit-book.
           move     fr-beg-pg                  to    edit-page-bgin.
           move     fr-end-pg                  to    edit-page-endg.

           *>----   trim leading spaces in book number
           move     01                         to    book-byte-cntr.
           perform  prnt-bkpg-book-byte
                    until  edit-book(book-byte-cntr:01)
                                               not = space.
           subtract book-byte-cntr             from  06
                                               giving book-lent.
           add      01                         to     book-lent.

           *>-----  trim leading spaces in page begin
           move     01                         to     page-bgin-byte-cntr.
           perform  prnt-bkpg-page-bgin-byte
                    until  edit-page-bgin(page-bgin-byte-cntr:01)
                                               not = space.
           subtract page-bgin-byte-cntr        from  06
                                               giving page-bgin-lent.
           add      01                         to     page-bgin-lent.

           *>----   trim leading spaces in page ending
           move     01                         to     page-endg-byte-cntr.
           perform  prnt-bkpg-page-endg-byte
                    until  edit-page-endg(page-endg-byte-cntr:01)
                                               not = space.
           subtract page-endg-byte-cntr        from  06
                                               giving page-endg-lent.
           add      01                         to     page-endg-lent.
           
           *>-----  end of trimming leading spaces.

           *>-----  handle number of pages
           move     fr-no-pages                to    edit-pags
           if       fr-no-pages                =     01
                    move   "pg"                to    edit-pags-desc
           else
                    move   "pgs"               to    edit-pags-desc.
           *>----   trim leading spaces in number of pages
           move     01                         to    edit-pags-byte-pntr.
           perform  prnt-bkpg-pags-byte
                         until  edit-pags(edit-pags-byte-pntr:01)
                                               not = space.
           subtract edit-pags-byte-pntr        from  03
                                               giving edit-pags-lent.
           add      01                         to    edit-pags-lent.
           *>--------------------------------

           
       prnt-bkpg-lasr-desc.
           move     space                      to     dt-desc.
           string   edt-rcd-ch(01:01)          delimited by size
                    " "                        delimited by size
                    "-"                        delimited by size
                    " "                        delimited by size
                    edit-book(book-byte-cntr:book-lent)
                                               delimited by size
                    " / "                      delimited by size
                    edit-page-bgin(page-bgin-byte-cntr:page-bgin-lent)
                                               delimited by size
                    " - "                      delimited by size
                    edit-page-endg(page-endg-byte-cntr:page-endg-lent)
                                               delimited by size
                    "     ("                   delimited by size
                    edit-pags(edit-pags-byte-pntr:edit-pags-lent)
                                               delimited by size
                    edit-pags-desc             delimited by "  "
                    ")"                        delimited by size
                                               into    dt-desc.
                           
       prnt-bkpg-itca-desc.
           move     space                      to     detl-itca-desc.
           string   edt-rcd-ch(01:01)          delimited by size
                    "-"                        delimited by size
                    edit-book(book-byte-cntr:book-lent)
                                               delimited by size
                    "/"                        delimited by size
                    edit-page-bgin(page-bgin-byte-cntr:page-bgin-lent)
                                               delimited by size
                    "-"                        delimited by size
                    edit-page-endg(page-endg-byte-cntr:page-endg-lent)
                                               delimited by size
                    " ("                       delimited by size
                    edit-pags(edit-pags-byte-pntr:edit-pags-lent)
                                               delimited by size
                    edit-pags-desc             delimited by "  "              
                    ")"                        delimited by size
                                               into    detl-itca-desc.
       
       prnt-bkpg-book-byte.
           add      01                         to    book-byte-cntr.
           
       prnt-bkpg-page-bgin-byte.
           add      01                         to    page-bgin-byte-cntr.
           
       prnt-bkpg-page-endg-byte.
           add      01                         to    page-endg-byte-cntr.
           
       prnt-bkpg-pags-byte.
           add      01                         to    edit-pags-byte-pntr.

       prnt-trim-file-nmbr.
	   set	    ef-ix		     to    01.
	   move     01			     to    byte-pntr.
	   move     fr-file-no		     to    edt-file-no.
	   perform  prnt-trim-file-incr
                    until    ef-ix           >     08
                    or       edit-file-nmbr-alpa(ef-ix)
					     not = space.
	   if	    ef-ix		     <=	   08
		    perform  prnt-trim-file-otpt-swch.

       prnt-trim-file-otpt-swch.
           if       dt-title(01:04)	     =	   "File"
                    perform  prnt-trim-file-otpt-lasr
           else
           	    perform  prnt-trim-file-otpt-itca.
       
       prnt-trim-file-otpt-lasr.
	   subtract byte-pntr		     from  08
					     giving
						   strg-lent.
	   add	    01			     to    strg-lent.
	   move	    edt-file-no (byte-pntr:strg-lent)
					     to  dt-desc.
           perform  print-detail.
                                                                    
       prnt-trim-file-otpt-itca.                                        
	   subtract byte-pntr		     from  08
					     giving
						   strg-lent.
	   add	    01			     to    strg-lent.
           move     edt-file-no (byte-pntr:strg-lent)
					     to    detl-itca-desc.
           perform  prnt-itca.
           
       prnt-trim-file-incr.                                                 
	   set	    ef-ix		     up by 01.                 
	   add	    01			     to    byte-pntr.

       print-detail.    
           if	    lasr-rcpt-sttn	     =      "y"
           	    move   dt-prnt	     to	    print-record  *> use laser detail line
           	    write  print-record      after  01
           else
           if       dymo-flag		     =	    space
           	    move   detl-itca-line    to     print-record  *> use ithaca detail line
           	    write  itca-rcrd         after  01
           else
           	    move   dt-prnt	     to	    print-record
           	    write  print-record      after  01.
           	    
           move     space                    to    dt-prnt.
           move     space                    to    print-record.
           move     space		     to	   detl-itca-line.
           move     space		     to    itca-rcrd.
           
           
       prnt-itca.
           move     detl-itca-line           to    itca-rcrd.
           write    itca-rcrd                after 01.
           move     space                    to    detl-itca-line.
           move     space                    to    itca-rcrd.
           
/
       look-for-period.                            
           set      wb-ix                     to     01.
           perform  scn-prd
                    until    wb-ix            >      63
                       or    ws-byt (wb-ix)   =      "."
                       or    ws-byt (wb-ix)   =      ",".
           if       ws-byt (wb-ix)            =      "."
           or       ws-byt (wb-ix)            =      ","
                    display  ss-warn-period
                    accept   ss-warn-period
                    display  ss-erase-err
                    add -01                   to     fld-no.
           move     space                     to     ws-nam.

       scn-prd.
           set      wb-ix     up              by     01.

       unstg-p-nam-1.
           perform  init-unstrg-nam.
           move     ws-nam1                   to     ws-nam.
           perform  scn-ws-nam                                                
                    until    wb-ix            >      63.
           perform  look-for-them.
           perform  look-for-thos.
           move     ws-frst                   to     fr-frst-name1.
           move     ws-last                   to     fr-last-name1.
           move     ws-midl                   to     fr-midl-name1.

       unstg-p-nam-2.
           perform  init-unstrg-nam.
           move     ws-nam2                   to     ws-nam.
           perform  scn-ws-nam
                    until    wb-ix            >      63.
           perform  look-for-them.
           perform  look-for-thos.
           move     ws-frst                   to     fr-frst-name2.
           move     ws-last                   to     fr-last-name2.
           move     ws-midl                   to     fr-midl-name2.
/
       init-unstrg-nam.
           move     space                     to     n-fld-1.
           move     space                     to     n-fld-2.
           move     space                     to     n-fld-3.
           move     space                     to     n-fld-4.
           move     space                     to     n-fld-5.
           move     space                     to     n-fld-6.
           move     space                     to     n-fld-7.
           move     space                     to     n-fld-8.
           set      n1-ix                     to     01.
           set      n2-ix                     to     01.
           set      n3-ix                     to     01.
           set      n4-ix                     to     01.
           set      n5-ix                     to     01.               
           set      n6-ix                     to     01.
           set      n7-ix                     to     01.
           set      n8-ix                     to     01.
           set      wb-ix                     to     01.
           move     01                        to     stg-cnt.
           move     space                     to     prv-byt.
           move     space                     to     ws-nam.
           move     space                     to     ws-frst.
           move     space                     to     ws-midl.
           move     space                     to     ws-last.

       scn-ws-nam.
           if       ws-byt   (wb-ix)          =      space
           and      prv-byt                   not =  space
                    add      01               to     stg-cnt.
           if       ws-byt   (wb-ix)          not =  space
                    perform  unstrg-swtch.
           move     ws-byt   (wb-ix)          to     prv-byt.
           set      wb-ix    up               by     01.
/
       unstrg-swtch.
           if       stg-cnt                   =      01
           and      n1-ix                     <      20
                    move     ws-byt (wb-ix)   to     n1-byt(n1-ix)
                    set      n1-ix  up        by     01.
           if       stg-cnt                   =      02
           and      n2-ix                     <      20
                    move     ws-byt (wb-ix)   to     n2-byt(n2-ix)
                    set      n2-ix  up        by     01.
           if       stg-cnt                   =      03
           and      n3-ix                     <      20
                    move     ws-byt (wb-ix)   to     n3-byt(n3-ix)
                    set      n3-ix  up        by     01.
           if       stg-cnt                   =      04
           and      n4-ix                     <      20
                    move     ws-byt (wb-ix)   to     n4-byt(n4-ix)
                    set      n4-ix  up        by     01.
           if       stg-cnt                   =      05
           and      n5-ix                     <      20
                    move     ws-byt (wb-ix)   to     n5-byt(n5-ix)
                    set      n5-ix  up        by     01.
           if       stg-cnt                   =      06
           and      n6-ix                     <      20
                    move     ws-byt (wb-ix)   to     n6-byt(n6-ix)
                    set      n6-ix  up        by     01.
           if       stg-cnt                   =      07
           and      n7-ix                     <      20
                    move     ws-byt (wb-ix)   to     n7-byt(n7-ix)
                    set      n7-ix  up        by     01.
           if       stg-cnt                   =      08
           and      n8-ix                     <      20
                    move     ws-byt (wb-ix)   to     n8-byt(n8-ix)
                    set      n8-ix  up        by     01.

       look-for-them.
           move     01                        to     stg-cnt.
           move     space                     to     end-scn.
           perform  scn-them
                    until    stg-cnt          >      08
                    or       end-scn          =      "E".
           if       end-scn                   =      "E"
                    perform  lod-them.

       scn-them.
           if       stg-cnt                   =      01
                    move     n-fld-1          to     ws-this.
           if       stg-cnt                   =      02
                    move     n-fld-2          to     ws-this.
           if       stg-cnt                   =      03
                    move     n-fld-3          to     ws-this.
           if       stg-cnt                   =      04
                    move     n-fld-4          to     ws-this.
           if       stg-cnt                   =      05
                    move     n-fld-5          to     ws-this.
           if       stg-cnt                   =      06
                    move     n-fld-6          to     ws-this.
           if       stg-cnt                   =      07
                    move     n-fld-7          to     ws-this.
           if       stg-cnt                   =      08
                    move     n-fld-8          to     ws-this.
           if       ws-this                   =      "JR"
           or       ws-this                   =      "SR"
           or       ws-this                   =      "II"
           or       ws-this                   =      "III"
           or       ws-this                   =      "ETAL"
           or       ws-this                   =      "ET AL"
                    move     "E"              to     end-scn
           else
                    add      01               to     stg-cnt.

       lod-them.
           if       stg-cnt                   =      01
                    move     space            to     n-fld-1.
           if       stg-cnt                   =      02
                    move     space            to     n-fld-2.
           if       stg-cnt                   =      03
                    move     space            to     n-fld-3.
           if       stg-cnt                   =      04
                    move     space            to     n-fld-4.
           if       stg-cnt                   =      05
                    move     space            to     n-fld-5.
           if       stg-cnt                   =      06
                    move     space            to     n-fld-6.
           if       stg-cnt                   =      07
                    move     space            to     n-fld-7.
           if       stg-cnt                   =      08
                    move     space            to     n-fld-8.
           move     ws-this                   to     ws-nam-dsc.
/
       look-for-thos.
           if       n-fld-8                   >      space
                    move     08               to     stg-cnt
           else
           if       n-fld-7                   >      space
                    move     07               to     stg-cnt
           else
           if       n-fld-6                   >      space
                    move     06               to     stg-cnt
           else
           if       n-fld-5                   >      space
                    move     05               to     stg-cnt
           else
           if       n-fld-4                   >      space
                    move     04               to     stg-cnt
           else
           if       n-fld-3                   >      space
                    move     03               to     stg-cnt
           else
           if       n-fld-2                   >      space
                    move     02               to     stg-cnt
           else
           if       n-fld-1                   >      space
                    move     01               to     stg-cnt
           else
                    move     zero             to     stg-cnt.
           if       stg-cnt                   =      02
                    perform  lod-lst-fst.
           if       stg-cnt                   =      03
                    perform  lod-lst-mdl-fst.
           if       stg-cnt                   =      04
                    perform  lod-lst-mdl-fst-fst.

       lod-lst-fst.
           move     n-fld-2                   to     ws-last.
           move     n-fld-1                   to     ws-frst.
           move     space                     to     ws-midl.

       lod-lst-mdl-fst.
           move     n-fld-3                   to     ws-last.
           move     n-fld-2                   to     ws-midl.
           move     n-fld-1                   to     ws-frst.
/
       lod-lst-mdl-fst-fst.
           move     n-fld-4                   to     ws-last.
           move     n-fld-3                   to     ws-midl.
           move     space                     to     ws-frst.
           string   n-fld-1
                    delimited                 by     " "
                    " "
                    delimited                 by     size
                    n-fld-2
                    delimited                 by     " "
                    " "
                    delimited                 by     size
                                              into   ws-frst.
/
       read-fee-file.
           move     01                        to     file-nmbr.
           read     fee-file
                    invalid key
                            move      "23"    to     file-stts.

       read-ixcd-file.
           move     02                        to     file-nmbr.
           read     ixcd-file
                    invalid key
                            move      "23"    to     file-stts.

       read-multi-tmp.
          move      03                        to     file-nmbr.
          read      multi-tmp
                    invalid key
                            move      "23"    to     file-stts.

       write-fee-record.
           move     01                        to     file-nmbr.
           write    fee-record.

       rewrite-fee-record.
           move     01                        to     file-nmbr.
           rewrite  fee-record.                                    

       release-code-record.
           move     9999                     to     ic-cd-tp.
           move     "XXXXXXXXX"              to     ic-id.
           move     lock-stts                to     file-stts.
           perform  read-ixcd-file
                    until    file-stts       not =  lock-stts.
                    
       inpt-xcel.                                                                             
           invoke   MSExcel       "new"         returning     ExcelObject.
           
           *>-----  Make excel visible
           invoke   ExcelObject  "setVisible"   using by      value 1.
           
           *>----                                                       
           invoke   ExcelObject  "getWorkBooks" returning     WorkBooksCol.  
             
           *>-----  Open Excel file
           invoke   WorkBooksCol  "Open"        using         xcel-file-path
                                                returning     WorkBook.        
                                                                        
           invoke   WorkBook      "getWorkSheets" 
                                                returning     Sheets.                          
           *>-----  select Sheet1
           invoke   Sheets        "getItem"     using         z"Sheet1"
                                                returning     Sheet.                 
           invoke   Sheet         "select".
     
       otpt-cell.    *> output cell.                                   
          *>-----------------------------------------------------           
          *>-----  Select the Cell
          *>-----------------------------------------------------
          invoke   Sheet    "getCells"	     using
					     by value  	rows-cntr            
					     by value  	clmn-cntr
					     returning 	Cell.

          *>-----------------------------------------------------
          *>-----  Set Cell Value
          *>-----------------------------------------------------      
          invoke   Cell     "setValue"	     using     	cell-valu.         
          
          *>-----------------------------------------------------
          *>-----  Finalize Cell Entry                                        
          *>-----------------------------------------------------
          invoke   Cell     "Finalize"	     returning 	Cell.
          move     space		     to	    	cell-valu.     
/                
      save-xcel.
          *>-------------------------------------------------------
          *>-----  Save Excel Workbook to c:\temp
          *>-------------------------------------------------------
          invoke   workbook "SaveAs" 	  using     	xcel-path.

      fnlz-xcel.                         
          invoke   Sheet	   "Finalize"	  returning 	Sheet.
          invoke   Sheets	   "Finalize"	  returning 	Sheets.
          invoke   WorkBook	   "Finalize"	  returning 	Workbook.
          invoke   WorkBooksCol    "Finalize"	  returning 	WorkBooksCol.
          
       proc-wait.   *> wait 1 second
          move     01			     to		wait-loop-cntr.
          perform  proc-wait-smpl                                                    
                   until   wait-loop-cntr =		zero.                
            	                                                                     
       proc-wait-smpl.                                                     
            accept   curr-time		     from	time.
            if       curr-secs		     not =      prev-secs
                     perform   proc-wait-decr.
                                                     
       proc-wait-decr.          
            add      -01		     to		wait-loop-cntr.
            move     curr-secs		     to		prev-secs.                    
                    
/
       cler-pay-flds.
           move     zero                     to        fr-receipt-no.
           move     zero                     to        fr-amt-recd.
           move     zero                     to        ws-change.
           move     zero                     to        ws-pay-amt1.
           move     zero                     to        ws-pay-amt2.
           move     zero                     to        ws-pay-amt3.
           move     zero                     to        ws-pay-amt4.
           move     zero                     to        ws-pay-amt5
           move     zero                     to        ws-pay-amt6
           move     zero                     to        ws-pay-amt7
           move     zero                     to        ws-pay-amt8
           move     zero                     to        ws-pay-amt9
           move     zero                     to        ws-pay-amt10
           move     zero                     to        ws-pay-amt11
           move     zero                     to        ws-pay-amt12
           move     zero                     to        ws-pay-amt13
           move     zero                     to        ws-pay-amt14
           move     space                    to        ws-pay-tp1.
           move     space                    to        ws-pay-tp2.
           move     space                    to        ws-pay-tp3.
           move     space                    to        ws-pay-tp4.
           move     space                    to        ws-pay-tp5.
           move     space                    to        ws-pay-tp6.
           move     space                    to        ws-pay-tp7.
           move     space                    to        ws-pay-tp8.
           move     space                    to        ws-pay-tp9.
           move     space                    to        ws-pay-tp10.
           move     space                    to        ws-pay-tp11.
           move     space                    to        ws-pay-tp12.
           move     space                    to        ws-pay-tp13.
           move     space                    to        ws-pay-tp14.
           move     space                    to        ws-chk-no1.
           move     space                    to        ws-chk-no2.
           move     space                    to        ws-chk-no3.
           move     space                    to        ws-chk-no4.
           move     space                    to        ws-chk-no5.
           move     space                    to        ws-chk-no6.
           move     space                    to        ws-chk-no7.
           move     space                    to        ws-chk-no8.
           move     space                    to        ws-chk-no9.
           move     space                    to        ws-chk-no10.
           move     space                    to        ws-chk-no11.
           move     space                    to        ws-chk-no12.
           move     space                    to        ws-chk-no13.
           move     space                    to        ws-chk-no14.
           move     space                    to        edt-pay-tp1.
           move     space                    to        edt-pay-tp2.
           move     space                    to        edt-pay-tp3.
           move     space                    to        edt-pay-tp4.
           move     space                    to        edt-pay-tp5.
           move     space                    to        edt-pay-tp6.
           move     space                    to        edt-pay-tp7.
           move     space                    to        edt-pay-tp8.
           move     space                    to        edt-pay-tp9.
           move     space                    to        edt-pay-tp10.
           move     space                    to        edt-pay-tp11.
           move     space                    to        edt-pay-tp12.
           move     space                    to        edt-pay-tp13.
           move     space                    to        edt-pay-tp14.
           display  ss-pay-flds.
           display  ss-chng-rvrs.
/
       cler-fee-rec.
*          move     space                    to    fr-doc-tp.
           move     zero                     to    fr-doc-cls.
           move     zero                     to    fr-doc-date.
           move     zero                     to    fr-doc-time.
           move     space                    to    fr-name1.
           move     "P"                      to    fr-name-tp1.
           move     space                    to    fr-name2.
           move     "P"                      to    fr-name-tp2.
           move     zero                     to    fr-beg-bk.
           move     zero                     to    fr-beg-pg.
           move     space                    to    fr-beg-sx.
           move     zero                     to    fr-no-pages.
           move     zero                     to    fr-end-bk.
           move     zero                     to    fr-end-pg.
           move     space                    to    fr-end-sx.
           move     zero                     to    fr-file-no.
           move     zero                     to    fr-rcd-fee.
           move     zero                     to    fr-addl-pg-fee.
           move     zero                     to    fr-trnsf-tax.
           move     zero                     to    fr-valuation.
           move     zero                     to    fr-pstg-fee.
           move     zero                     to    fr-pnly-fee.
           move     zero                     to    fr-addl-fee.
           move     zero                     to    fr-afrd-hous.
           move     zero                     to    fr-stat-fees.
           move     zero                     to    fr-clrk-fees.
           move     zero                     to    fr-clrk-cmsn.
           move     zero                     to    fr-ar.
           move     space                    to    ws-pay-tp1.
           move     zero                     to    ws-pay-amt1.
           move     space                    to    ws-chk-no1.
           move     space                    to    ws-pay-tp2.
           move     zero                     to    ws-pay-amt2.
           move     space                    to    ws-chk-no2.
           move     space                    to    ws-pay-tp3.
           move     zero                     to    ws-pay-amt3.
           move     space                    to    ws-chk-no3.
           move     space                    to    ws-pay-tp4.
           move     zero                     to    ws-pay-amt4.
           move     space                    to    ws-chk-no4.
           move     space                    to    ws-pay-tp5.
           move     zero                     to    ws-pay-amt5.
           move     space                    to    ws-chk-no5.
           move     space                    to    ws-pay-tp6.
           move     zero                     to    ws-pay-amt6.
           move     space                    to    ws-chk-no6.
           move     space                    to    ws-pay-tp7.
           move     zero                     to    ws-pay-amt7.
           move     space                    to    ws-chk-no7.
           move     space                    to    ws-pay-tp8.
           move     zero                     to    ws-pay-amt8.
           move     space                    to    ws-chk-no8.
           move     space                    to    ws-pay-tp9.
           move     zero                     to    ws-pay-amt9.
           move     space                    to    ws-chk-no9.
           move     space                    to    ws-pay-tp10.
           move     zero                     to    ws-pay-amt10.
           move     space                    to    ws-chk-no10.
           move     space                    to    ws-pay-tp11.
           move     zero                     to    ws-pay-amt11.
           move     space                    to    ws-chk-no11.
           move     space                    to    ws-pay-tp12.
           move     zero                     to    ws-pay-amt12.
           move     space                    to    ws-chk-no12.
           move     space                    to    ws-pay-tp13.
           move     zero                     to    ws-pay-amt13.
           move     space                    to    ws-chk-no13.
           move     space                    to    ws-pay-tp14.
           move     zero                     to    ws-pay-amt14.
           move     space                    to    ws-chk-no14.
           move     zero                     to    fr-amt-due.
           move     zero                     to    fr-amt-recd.
           move     zero                     to    ws-change.
           move     space                    to    fr-bkkp-cd.
           move     space                    to    fr-rcd-ch.
           move     space                    to    fr-clctn-ch.
           move     space                    to    fr-clk-id.
           move     space                    to    fr-post-flag.
           move     space                    to    fr-prntd-flag.
           move     space                    to    fr-post-bkkp.
           move     zero                     to    fr-terminal-no.
           move     zero                     to    fr-bk-to-rcd-in.
           move     space                    to    fr-sngl-mult.
           move     space                    to    fr-nam-dsc-1.
           move     space                    to    fr-nam-dsc-2.
           move     space                    to    fr-filler.
/
       dsply-brdr.
           move     01                       to     cl-no.
           move     02                       to     ln-no.
           move     chr-186                  to     vt-chr.
           perform  dsply-vrt
                    until   ln-no            =      24.
           move     80                       to     cl-no.
           move     02                       to     ln-no.
           move     chr-186                  to     vt-chr.
           perform  dsply-vrt
                    until   ln-no            =      24.
           move     70                       to     cl-no.
           move     22                       to     ln-no.
           move     chr-179                  to     vt-chr.
           perform  dsply-vrt
                    until   ln-no            =      24.
           display  ss-brdr.

       dsply-vrt.
           display  ss-vrt.
           add      01                       to     ln-no.

       dsply-hedr.
           accept   sys-date                 from   date.
           display  ss-hedr.
           perform  smpl-tim.
/
       smpl-tim.
           accept   sys-time                 from   time.
           if       sys-sc                   not = prv-sc
                    perform  dsply-tim.

       dsply-tim.
           if       sys-hr                   >      11
                    move     "p"             to     sys-mrd
           else
                    move     "a"             to     sys-mrd.
           if       sys-hr                   >      12
                    add     -12              to     sys-hr.
           display  ss-tim.
           move     sys-sc                   to     prv-sc.
           add      01                       to     rec-cnt.

       eras-bsy.
           display  ss-ers-bsy.
           move     space                    to     was-bsy.

       clos-fils.
           move     01                       to     file-nmbr.
           close    fee-file.
           move     02                       to     file-nmbr.
           close    ixcd-file.
           move     03                       to     file-nmbr.
           close    multi-tmp.
           move     04                       to     file-nmbr.
           close    fee-rcpt.
           move     05                       to     file-nmbr.
           close    fees-jrnl.
           move     06                       to     file-nmbr.
           close    indx-code.                                                
           move     07                       to     file-nmbr.
           close    notr-file.
           move     file-nmbr-deed-list      to     file-nmbr.
           close    deed-list.
           move     file-nmbr-dcmt-xref      to     file-nmbr.
           close    dcmt-xref.

