-- ***************************************** Update Transaction **************************************************

UPDATE transact SET trn_desc = amount || ' transferred from ' || sourcedep || ' to ' || desdep;

UPDATE transact SET amount = amount / 1000 WHERE amount > 1000000;

UPDATE transact SET amount = amount / 100 WHERE amount > 9999;



-- ***************************************** Question 1 **************************************************


CREATE OR REPLACE PROCEDURE checkNatCode (IN _natCode_ VARCHAR(10) , OUT _result_ INTEGER)
	LANGUAGE plpgsql
	AS $$
	
		DECLARE _sum INTEGER := 0;
	
	BEGIN
								

										
					FOR i IN 1..LENGTH(_natCode_) LOOP
							_sum = _sum + SUBSTR(_natCode_, i , 1)::DECIMAL * (LENGTH(_natCode_) - i + 1);
							
							raise notice 'sum: % ', _sum;
							raise notice 'i: % ', i;

							IF i = LENGTH(_natCode_) - 1 THEN
								EXIT;
							ELSE 
								i = i + 1; 
							END IF;
							
				END LOOP;

				IF (_sum % 11 < 2 AND SUBSTR(_natCode_, LENGTH(_natCode_) , 1)::INTEGER  = (_sum % 11)) OR
					 (_sum % 11 >= 2 AND SUBSTR(_natCode_, LENGTH(_natCode_) , 1)::INTEGER = 11 - (_sum % 11)) THEN
								raise notice 'thats ok ... ';
								_result_ = 1;
				ELSE 
								raise notice 'not ok ... %' , SUBSTR(_natCode_, LENGTH(_natCode_) , 1);
								_result_ = 0;
				END IF;
				raise notice 'Value: % ', _sum;
				RETURN;
-- 
																 
	END; $$;



-- ***************************************** Question 2 **************************************************

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Track Previous Transactions $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


CREATE OR REPLACE FUNCTION trackPreviousTransactions (
	
	_SrcDep_ INTEGER ,
	_DesDep_ INTEGER ,
	_Amount_ BIGINT ,
	_TrnDate_ Date ,
	_TrnTime_ VARCHAR(15)	,
	i BIGINT ,
	_sum_ BIGINT
)
	RETURNS TABLE (VoucherId VARCHAR(10) , TrnDate DATE , TrnTime VARCHAR(15) , Amount BIGINT , 
						SourceDep INTEGER , DesDep INTEGER , Branch_ID INTEGER , Trn_Desc VARCHAR(100))
	LANGUAGE plpgsql

	AS $$

	DECLARE temprow RECORD = NULL;


	BEGIN FOR temprow IN
			SELECT * FROM transact
				WHERE transact.desdep = _SrcDep_ AND (transact.trndate < _TrnDate_ OR 
													(transact.trndate = _TrnDate_ AND transact.trntime < _TrnTime_)) 
													ORDER BY (transact.trndate, transact.trntime) ASC
			LOOP
					raise notice 'sum before % ', _sum_;
					_sum_ = _sum_ + temprow.amount;
					raise notice 'transact % from % to % => sum : % , amount : % ', temprow.amount, _SrcDep_, _DesDep_, _sum_, _Amount_;

					IF _sum_ <= (_Amount_ * 1.1) 
						AND EXISTS (SELECT * FROM deposit WHERE deposit.dep_id = temprow.sourcedep) 
						AND EXISTS (SELECT * FROM deposit WHERE deposit.dep_id = temprow.desdep) THEN	
							
						i = i + 1;

						RETURN QUERY  
						SELECT * FROM trackPreviousTransactions(temprow.sourcedep , temprow.desdep , temprow.amount , temprow.trndate , temprow.trntime , 0 , 0);
					END IF;
			END LOOP;
			RETURN QUERY 
			(
				(
				 SELECT * FROM transact t
					WHERE t.desdep = _SrcDep_ AND  t.trndate =  (
																	SELECT min(t2.trndate) FROM transact t2 
																	WHERE t2.desdep = _SrcDep_ AND 
																		t2.trndate < _TrnDate_ 
																		OR
																		(t2.trndate = _TrnDate_ AND t2.trntime < _TrnTime_)
																)
				)
				UNION
				(SELECT * FROM transact
					WHERE transact.desdep = _SrcDep_ AND (transact.trndate < _TrnDate_ OR (transact.trndate = _TrnDate_ AND transact.trntime < _TrnTime_)) 				ORDER BY (transact.trndate, transact.trntime) ASC LIMIT i)
			);

END $$;


SELECT * FROM trackPreviousTransactions(508 , 505 , 100000 , '2020-03-25' , '09:00:00' , 0 , 0);



-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Track Subsequent Transactions $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



CREATE OR REPLACE FUNCTION trackSubsequentTransactions (
	
	_SrcDep_ INTEGER ,
	_DesDep_ INTEGER ,
	_Amount_ BIGINT ,
	_TrnDate_ Date ,
	_TrnTime_ VARCHAR(15)	,
	i BIGINT ,
	_sum_ BIGINT
)
	RETURNS TABLE (VoucherId VARCHAR(10) , TrnDate DATE , TrnTime VARCHAR(15) , Amount BIGINT , 
						SourceDep INTEGER , DesDep INTEGER , Branch_ID INTEGER , Trn_Desc VARCHAR(100))
	LANGUAGE plpgsql

	AS $$

	DECLARE temprow RECORD = NULL;


	BEGIN FOR temprow IN
		SELECT * FROM transact
			WHERE transact.sourcedep = _DesDep_ AND (transact.trndate > _TrnDate_ OR 
																(transact.trndate = _TrnDate_ AND transact.trntime > _TrnTime_)) 
																ORDER BY (transact.trndate, transact.trntime) ASC
		LOOP
				raise notice 'sum before % ', _sum_;
				_sum_ = _sum_ + temprow.amount;
				raise notice 'transact % from % to % => sum : % , amount : % ', temprow.amount, _SrcDep_, _DesDep_, _sum_, _Amount_;

				IF _sum_ <= (_Amount_ * 1.1) 
					AND EXISTS (SELECT * FROM deposit WHERE deposit.dep_id = temprow.sourcedep) 
					AND EXISTS (SELECT * FROM deposit WHERE deposit.dep_id = temprow.desdep) THEN	
						
					i = i + 1;

					RETURN QUERY  
					SELECT * FROM trackSubsequentTransactions(temprow.sourcedep , temprow.desdep , temprow.amount , temprow.trndate , temprow.trntime , 0 , 0);
					
				END IF;
	 END LOOP;
		RETURN QUERY 
		(
			(
			 SELECT * FROM transact t
				WHERE t.sourcedep = _DesDep_ AND  t.trndate =  (
																	SELECT min(t2.trndate) FROM transact t2 
																	WHERE t2.sourcedep = _DesDep_ AND 
																		t2.trndate > _TrnDate_ 
																		OR
																		(t2.trndate = _TrnDate_ AND t2.trntime > _TrnTime_)
																)
			)
			UNION
			(SELECT * FROM transact
				WHERE transact.sourcedep = _DesDep_ AND (transact.trndate > _TrnDate_ OR (transact.trndate = _TrnDate_ AND transact.trntime > _TrnTime_)) 				ORDER BY (transact.trndate, transact.trntime) ASC LIMIT i)
		);

END $$;



SELECT * FROM trackSubsequentTransactions(500 , 501 , 100000 , '2020-03-25' , '09:00:00' , 0 , 0);


-- SELECT min(t2.trndate) FROM 
-- transact t2 WHERE t2.sourcedep = 505 AND t2.trndate > '2000-03-25' OR 
-- (t2.trndate = '2000-03-25' AND t2.trntime > '09:00:00')

-- SELECT * from transact WHERE sourcedep = 501



-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Union of that Functions $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


CREATE OR REPLACE FUNCTION TrackRelatedTransactions (
	_SrcDep_ INTEGER ,
	_DesDep_ INTEGER ,
	_Amount_ BIGINT ,
	_TrnDate_ Date ,
	_TrnTime_ VARCHAR(15)
)
	RETURNS TABLE (VoucherId VARCHAR(10) , TrnDate DATE , TrnTime VARCHAR(15) , Amount BIGINT , 
						SourceDep INTEGER , DesDep INTEGER , Branch_ID INTEGER , Trn_Desc VARCHAR(100))
	LANGUAGE plpgsql

	AS $$
	
	BEGIN
	
		RETURN QUERY 
		(
			SELECT * FROM trackSubsequentTransactions(_SrcDep_ , _DesDep_ , _Amount_ , _TrnDate_ , _TrnTime_ , 0 , 0) 
				UNION
			SELECT * FROM trackPreviousTransactions(_SrcDep_ , _DesDep_ , _Amount_ , _TrnDate_ , _TrnTime_ , 0 , 0) 
		);

END $$;

SELECT * FROM TrackRelatedTransactions(510 , 504 , 1000 , '2020-03-25' , '09:00:00');