CREATE OR REPLACE PROCEDURE Calculate_VAT(
    p_total_amount IN NUMBER,
    p_vat_amount OUT NUMBER,
    p_final_amount OUT NUMBER
) IS
    -- Constant declaration
    c_vat_rate CONSTANT NUMBER := 0.18;
    
    -- Local variable
    v_vat_calculation NUMBER;
    
    -- Custom exception
    e_invalid_amount EXCEPTION;
BEGIN
    -- Input validation
    IF p_total_amount <= 0 THEN
        RAISE e_invalid_amount;
    END IF;
    
    -- Calculate VAT
    v_vat_calculation := p_total_amount * c_vat_rate;
    
    -- Set output parameters
    p_vat_amount := ROUND(v_vat_calculation, 2);
    p_final_amount := ROUND(p_total_amount + v_vat_calculation, 2);
    
    -- Display results
    DBMS_OUTPUT.PUT_LINE('Transaction Details:');
    DBMS_OUTPUT.PUT_LINE('-------------------');
    DBMS_OUTPUT.PUT_LINE('Base Amount: ' || TO_CHAR(p_total_amount, 'FM999,999,999') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('VAT Amount: ' || TO_CHAR(p_vat_amount, 'FM999,999,999') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('Final Amount: ' || TO_CHAR(p_final_amount, 'FM999,999,999') || ' RWF');

EXCEPTION
    WHEN e_invalid_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Transaction amount must be greater than zero');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END Calculate_VAT;
/

-- Example usage:
DECLARE
    v_vat NUMBER;
    v_total NUMBER;
BEGIN
    Calculate_VAT(100000, v_vat, v_total);
END;
/

SET SERVEROUTPUT ON;
EXEC Calculate_VAT(100000, :v_vat, :v_total);