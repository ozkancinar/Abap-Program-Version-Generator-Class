class ZCL_VERSION_GENERATOR definition
  public
  final
  create public .

public section.

  class-methods GENERATE_VERSION
    importing
      value(IV_PROGNAME) type CHAR40
    exporting
      !ET_RETURN type ZOZ_PROG_VERSION_TT .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VERSION_GENERATOR IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_VERSION_GENERATOR=>GENERATE_VERSION
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PROGNAME                    TYPE        CHAR40
* | [<---] ET_RETURN                      TYPE        ZOZ_PROG_VERSION_TT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GENERATE_VERSION.

    DATA: lv_treename TYPE eu_t_name,
          lt_node TYPE STANDARD TABLE OF snodetext  .

    DATA: l_e071            TYPE e071,
          l_state           TYPE d010sinf-r3state,
          l_versnum         TYPE vrsd-versno.

    DATA: ls_return LIKE LINE OF et_return.

    lv_treename = 'PG_' && iv_progname. "sy-repid.

    CALL FUNCTION 'WB_TREE_SELECT'
      EXPORTING
        treename            = lv_treename
*       with_dialog         =     " Internal
        ignore_current_tree = 'X'
*       wb_manager          =     " Workbench Manager
*  IMPORTING
*       devclass            =
      TABLES
        nodetab             = lt_node    " Internal: Node ID
      EXCEPTIONS
        not_found           = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


*DELETE lt_node WHERE type NE 'OI' AND type NE 'OP'.

    LOOP AT lt_node ASSIGNING FIELD-SYMBOL(<fs_node>) WHERE type = 'OI' OR type = 'OP'.
      l_e071-pgmid    = 'LIMU'.
      l_e071-object   = 'REPS'.
      l_e071-obj_name = <fs_node>-name.
      l_state = 'A'.

      CALL FUNCTION 'SVRS_AFTER_CHANGED_ONLINE_NEW'
        EXPORTING
          e071_entry  = l_e071
          status      = l_state
        IMPORTING
          version_new = l_versnum
        EXCEPTIONS
          OTHERS      = 1.

      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ls_return-obj_name = <fs_node>-name.
        ls_return-version = l_versnum.
        ls_return-mesaj = text-002.
      ELSE.
        IF l_versnum <> 0.
          ls_return-obj_name = <fs_node>-name.
          ls_return-version = l_versnum.
          ls_return-mesaj = text-001.
*          MESSAGE 'Başarılı' TYPE 'S'.
        ELSE.
*      MESSAGE s013.
        ENDIF.
      ENDIF.
      APPEND ls_return TO et_return.
      CLEAR: l_e071, l_state, ls_return.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.