CREATE PROCEDURE dbo.p_fsoReadAll (
    @in_filePath VarChar(260),   
    @out_contents VarChar(1000)
)
AS
BEGIN
    DECLARE @hr Int
    DECLARE @o_fso Int, @o_file Int, @sz_contents VarChar(1000)
    DECLARE @noErr Bit, @errMethod VarChar(255)
    DECLARE @src VarChar(255), @desc VarChar(255)
    
    SET @noErr = 1
    
    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @o_fso OUT
    IF @hr = 0
    BEGIN
        EXEC @hr = sp_OAMethod @o_fso, 'OpenTextFile', @o_file OUT, @in_filePath, 1
        IF @hr <> 0
        BEGIN
            EXEC sp_OAGetErrorInfo @o_fso, @src OUT, @desc OUT
            SET @errMethod = 'sp_OAMethod: OpenTextFile'
            SET @noErr = 0
        END
    END
    
    IF @hr = 0
    BEGIN
        EXEC @hr = sp_OAMethod @o_file, 'ReadAll', @sz_contents OUT
        IF @hr <> 0
        BEGIN
            EXEC sp_OAGetErrorInfo @o_fso, @src OUT, @desc OUT
            SET @errMethod = 'sp_OAMethod: ReadAll'
            SET @noErr = 0
        END
    END
    
    IF @hr = 0
    BEGIN
        EXEC @hr = sp_OADestroy @o_file
        IF @hr <> 0
        BEGIN
            EXEC sp_OAGetErrorInfo @o_fso, @src OUT, @desc OUT
            SET @errMethod = 'sp_OADestroy: File Object'
            SET @noErr = 0
        END
    END
    
    IF @hr = 0
    BEGIN
        EXEC @hr = sp_OADestroy @o_fso
        IF @hr <> 0
        BEGIN
            EXEC sp_OAGetErrorInfo @o_fso, @src OUT, @desc OUT
            SET @errMethod = 'sp_OADestroy: FSO Object'
            SET @noErr = 0
        END
    END
    
    SET @out_contents = @sz_contents
END
GO