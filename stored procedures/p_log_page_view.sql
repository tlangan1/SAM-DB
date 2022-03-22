drop procedure p_log_page_view
go

create procedure p_log_page_view
@page_and_path varchar(100)
, @request_value_user_agent varchar(500)
, @suspected_device_type varchar(10)
AS

/* This prevents messages from being sent back...improves performance */
SET NOCOUNT ON;

/* for error handling */
DECLARE @ErrorMessage nvarchar(4000)

BEGIN
declare @next_page_view_id int
select @next_page_view_id = isnull(MAX(page_view_id), 0) + 1 from page_view_log

Begin TRY
	insert into page_view_log values (@next_page_view_id
	, GETDATE()
	, @page_and_path
	, @request_value_user_agent
	, @suspected_device_type)
END TRY
BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE();
END CATCH
END

select @ErrorMessage as error_message;
go

grant execute on p_log_page_view to public;
go
