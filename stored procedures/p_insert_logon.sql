drop procedure p_insert_logon
go

create procedure p_insert_logon
@email_addr varchar(200)
AS

declare @user_id int

/* This prevents messages from being sent back...improves performance */
SET NOCOUNT ON;

/* for error handling */
DECLARE @ErrorMessage nvarchar(4000)

select @user_id = max(user_id) from sam_user where email_addr = @email_addr

if (@@ROWCOUNT > 0)
	BEGIN
	declare @sam_user_logon_history_id int
	select @sam_user_logon_history_id = isnull(MAX(sam_user_logon_history_id), 0) + 1 from sam_user_logon_history

	Begin TRY
		insert into sam_user_logon_history values (@sam_user_logon_history_id
		, @user_id
		, getdate())
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE();
	END CATCH
	END

select @ErrorMessage as error_message;
go

grant execute on p_insert_logon to public;
go
