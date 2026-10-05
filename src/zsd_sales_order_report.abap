*&---------------------------------------------------------------------*
*& Report ZSD_SALES_ORDER_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_sales_order_report.


TABLES:
  vbak,
  vbap,
  kna1,
  makt
  .


DATA:
  alv         TYPE REF TO cl_salv_table
  .


DATA: alv_display   TYPE REF TO cl_salv_display_settings.





TYPES:BEGIN OF ty_sales_item,
        vbeln  TYPE  vbak-vbeln,
        erdat  TYPE  vbak-erdat,
        vkorg  TYPE  vbak-vkorg,
        kunnr  TYPE  vbak-kunnr,
        name1  TYPE  kna1-name1,
        posnr  TYPE  vbap-posnr,
        matnr  TYPE  vbap-matnr,
        maktx  TYPE  makt-maktx,
        kwmeng TYPE  vbap-kwmeng,
        vrkme  TYPE  vbap-vrkme,
        netwr  TYPE  vbap-netwr,
        waerk  TYPE  vbak-waerk,

      END OF ty_sales_item.

DATA:
  gt_sales_items  TYPE TABLE OF ty_sales_item.







"Selection Screen


SELECTION-SCREEN BEGIN OF BLOCK sels WITH FRAME TITLE TEXT-b01.



SELECT-OPTIONS: s_vbeln  FOR  vbak-vbeln,
                s_erdat  FOR  vbak-erdat OBLIGATORY,
                s_kunnr  FOR  vbak-kunnr,
                s_vkorg  FOR  vbak-vkorg.



SELECTION-SCREEN END OF BLOCK sels .




START-OF-SELECTION.

  PERFORM get_data.


  IF  gt_sales_items IS INITIAL.
    MESSAGE 'No data found for the selected criteria' TYPE 'I'.
    RETURN.
  ENDIF.

  PERFORM display_data.






*---------------------------------------------------------------------*
*      Form  GET_DATA
*---------------------------------------------------------------------*

FORM get_data .




  SELECT
   a~vbeln,
   a~erdat,
   a~vkorg,
   a~kunnr,
   c~name1,
   b~posnr,
   b~matnr,
   d~maktx,
   b~kwmeng,
   b~vrkme,
   b~netwr,
   a~waerk

INTO CORRESPONDING FIELDS OF TABLE @gt_sales_items


    FROM vbak AS a INNER JOIN vbap AS b
    ON   a~vbeln = b~vbeln
    LEFT OUTER JOIN kna1 AS c
    ON   a~kunnr = c~kunnr
    LEFT OUTER JOIN makt AS d
    ON   b~matnr = d~matnr AND
         d~spras =  @sy-langu



    WHERE
    a~vbeln IN @s_vbeln AND
    a~erdat IN @s_erdat AND
    a~kunnr IN @s_kunnr AND
    a~vkorg IN @s_vkorg
    .




ENDFORM.                    "get_data






*---------------------------------------------------------------------*
*      Form  DISPLAY_DATA
*---------------------------------------------------------------------*

FORM display_data.
  DATA: lr_functions  TYPE REF TO cl_salv_functions_list,
        lr_selections TYPE REF TO cl_salv_selections,
        lr_columns    TYPE REF TO cl_salv_columns_table,
        lr_sorts      TYPE REF TO cl_salv_sorts,
        lo_ref        TYPE REF TO cx_root,
        lv_err_text   TYPE string.

  CLEAR lv_err_text.
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = alv
                              CHANGING  t_table      =  gt_sales_items ).
    CATCH cx_salv_msg INTO lo_ref.
      lv_err_text = lo_ref->get_text( ).
  ENDTRY.

  IF NOT lv_err_text IS INITIAL.
    MESSAGE e001(00) WITH lv_err_text.
  ENDIF.

*** Set layout handling
  DATA : lo_layouts   TYPE REF TO cl_salv_layout,
         ls_layoutkey TYPE        salv_s_layout_key.


  PERFORM write_alv_header.

  lo_layouts = alv->get_layout( ).           "Get Layout of Table
  ls_layoutkey-report  = sy-repid .                    "Set Report ID as Layout Key
  lo_layouts->set_key( ls_layoutkey ) .                 "Set Report Id to Layout
  lo_layouts->set_default( if_salv_c_bool_sap=>true ) . "Set Default Variant
  lo_layouts->set_save_restriction( if_salv_c_layout=>restrict_none ). "No Restriction to Save Layout




  alv_display = alv->get_display_settings( ).

  alv_display->set_list_header( ' **** SALES REPORT **** ' ).
  alv_display->set_striped_pattern( abap_true ).



* functions
  lr_functions = alv->get_functions( ).
  lr_functions->set_all( ).

  lr_columns = alv->get_columns( ).
  lr_columns->set_optimize( ).



***** Default sort *****

  TRY.
      lr_sorts = alv->get_sorts( ).

      lr_sorts->add_sort(
        columnname = 'VBELN'
        sequence   = if_salv_c_sort=>sort_up ).

      lr_sorts->add_sort(
        columnname = 'POSNR'
        sequence   = if_salv_c_sort=>sort_up ).

    CATCH cx_salv_not_found INTO DATA(lx_not_found).
      MESSAGE lx_not_found->get_text( ) TYPE 'E'.

    CATCH cx_salv_existing INTO DATA(lx_existing).
      MESSAGE lx_existing->get_text( ) TYPE 'E'.

    CATCH cx_salv_data_error INTO DATA(lx_data_error).
      MESSAGE lx_data_error->get_text( ) TYPE 'E'.
  ENDTRY.



  lr_selections = alv->get_selections( ).
  lr_selections->set_selection_mode( if_salv_c_selection_mode=>multiple ).



  alv->display( ).
ENDFORM.                    "DISPLAY_DATA




*---------------------------------------------------------------------*
*      Form  WRITE_ALV_HEADER
*---------------------------------------------------------------------*

FORM write_alv_header .

  DATA: lr_grid TYPE REF  TO cl_salv_form_layout_grid,
        l_text  TYPE string,
        l_date  TYPE char10,
        l_time  TYPE char10,
        l_title TYPE char50.


* Write header of ALV
  CREATE OBJECT lr_grid.

* Program Name
  CLEAR l_text.
  WRITE sy-title TO l_title. " Program name
  CONCATENATE TEXT-d01 l_title INTO l_text SEPARATED BY space.
  CONCATENATE l_text ',' INTO l_text.

* Execution Date & Time

  WRITE sy-datum TO l_date DD/MM/YYYY. "Date
  WRITE sy-uzeit TO l_time. "Time
  CONCATENATE l_text
  TEXT-d02 l_date '&' l_time INTO l_text SEPARATED BY space.

  lr_grid->create_text(
  row         = 1
  column      = 1
  text        = l_text ).


  " Set header in ALV
  alv->set_top_of_list( lr_grid ).


ENDFORM.                    "write_alv_header
