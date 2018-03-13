
CREATE FUNCTION dbo.SplitStrings( @strString VARCHAR(4000), @delimiter CHAR(1))

RETURNS  @Result TABLE(Id VARCHAR(255))
AS
BEGIN
 
      DECLARE @x XML 
      SELECT @x = CAST('<A>'+ REPLACE(@strString, @delimiter,'</A><A>')+ '</A>' AS XML)
     
      INSERT INTO @Result            
      SELECT t.value('.', 'VARCHAR(255)') AS inVal
      FROM @x.nodes('/A') AS x(t)
 

    RETURN
END
