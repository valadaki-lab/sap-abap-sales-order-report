# SAP ABAP Sales Order Report

`ZSD_SALES_ORDER_REPORT` is a classical ABAP report for SAP ECC that displays sales order item data using Open SQL and `CL_SALV_TABLE`.

The project was created as a small portfolio report focused on data retrieval, JOIN logic, selection-screen design, and ALV presentation.

## Features

- Selection by:
  - Sales Order
  - Creation Date
  - Customer
  - Sales Organization
- Mandatory creation-date selection
- Empty-result handling
- Single Open SQL statement using JOINs
- Customer name retrieval from `KNA1`
- Material description retrieval from `MAKT`
- Material description filtered by current logon language using `SY-LANGU`
- SALV output with:
  - Standard ALV functions
  - Optimized column widths
  - Zebra pattern
  - Default sorting by Sales Order and Item
  - Layout saving
  - Report header with execution date and time

## SAP Tables Used

| Table | Purpose |
|---|---|
| `VBAK` | Sales document header data |
| `VBAP` | Sales document item data |
| `KNA1` | Customer master data |
| `MAKT` | Material descriptions |

## Selection Screen

The report provides the following selection criteria:

- `S_VBELN` – Sales Order
- `S_ERDAT` – Creation Date
- `S_KUNNR` – Customer
- `S_VKORG` – Sales Organization

The creation date is mandatory in order to limit unrestricted data selection.

## Data Retrieval

The report retrieves the required data using a single Open SQL statement.

`VBAK` and `VBAP` are joined using an `INNER JOIN` because the report displays sales-order item data.

`KNA1` and `MAKT` are joined using `LEFT OUTER JOIN` so that missing descriptive data does not remove the corresponding sales-order item from the result set.

The material description language is restricted in the JOIN condition:

```abap
LEFT OUTER JOIN makt AS d
  ON b~matnr = d~matnr
 AND d~spras = @sy-langu
```

This preserves the outer-join behavior while retrieving the material description for the user's current logon language.

## Output Fields

The ALV displays:

- Sales Order
- Creation Date
- Sales Organization
- Customer
- Customer Name
- Item Number
- Material
- Material Description
- Order Quantity
- Sales Unit
- Net Value
- Currency

## ALV Features

The result is displayed with `CL_SALV_TABLE`.

The ALV configuration includes:

- Standard SAL
