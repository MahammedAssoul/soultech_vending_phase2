# Phase 2 Data Model

Machine 1:N Sale
Machine 1:N RestockingRecord
Machine 1:N CashReading
Product 1:N RestockingRecord

Profit = Sales Revenue - Product Cost - Location Commission - Other Recorded Operating Costs
Location Commission = Sales Revenue × commissionPercent / 100
Cash Difference = Actual Cash - Expected Cash

Expected Cash should be derived from the opening reading + cash sales - cash movements/change added, according to the selected reconciliation method.
