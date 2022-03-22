drop procedure p_insert_user
go

create procedure p_insert_user
@email_addr varchar(200)
, @password varchar(30)
, @first_name varchar(50)
, @last_name varchar (50)
, @firm_name varchar (50)
, @primary_role varchar(200)
, @phone_number varchar(15)
, @street_address1 varchar(100)
, @street_address2 varchar(100)
, @city varchar(50)
, @state char(2)
, @zip_code varchar(13)
, @on_mailing_list varchar(3)
AS

/* This prevents messages from being sent back...improves performance */
SET NOCOUNT ON;

/* for error handling */
DECLARE @ErrorMessage nvarchar(4000)

if (select count(*) from sam_user where email_addr = @email_addr) > 0
	BEGIN
	Select @ErrorMessage = 'This email address is already registered with Stringer Asset Management.'
	END
else
	BEGIN
	declare @next_user_id int
	select @next_user_id = isnull(MAX(user_id), 0) + 1 from sam_user

	Begin TRY
		insert into sam_user values (@next_user_id
		, @email_addr
		, @password
		, @first_name
		, @last_name
		, @firm_name
		, @primary_role
		, @phone_number
		, @street_address1
		, @street_address2
		, @city
		, @state
		, @zip_code
		, @on_mailing_list
		, 'Active'
		, GETDATE()
		, null
		, null)
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE();
	END CATCH
	END

select @ErrorMessage as error_message;
go

grant execute on p_insert_user to public;
go
