
CREATE FUNCTION dbo.SplitInts( @strString VARCHAR(4000), @delimiter CHAR(1))

RETURNS  @Result TABLE(Id INT)
AS
BEGIN
 
      DECLARE @x XML 
      SELECT @x = CAST('<A>'+ REPLACE(@strString, @delimiter,'</A><A>')+ '</A>' AS XML)
     
      INSERT INTO @Result            
      SELECT t.value('.', 'int') AS inVal
      FROM @x.nodes('/A') AS x(t)
 

    RETURN
END
