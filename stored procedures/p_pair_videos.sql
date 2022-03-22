drop procedure p_pair_videos
go

create procedure p_pair_videos
@purpose varchar(10)
as
BEGIN
declare @max_item_id int, @item_count int, @modulo_a int, @modulo_b int

select @max_item_id = max(item_id) from sam_news_perspectives where item_type = 'video' and purpose = @purpose
select @item_count = count(*) from sam_news_perspectives where item_type = 'video' and purpose = @purpose and item_id <> @max_item_id

if (@item_count % 2 = 0)
	BEGIN
	select @modulo_a = 1
	select @modulo_b = 0
	END
else
	BEGIN
	select @modulo_a = 0
	select @modulo_b = 1
	END

select rownumber as rownumber_a, heading as heading_a, item_text as item_text_a, video as video_a
, heading as heading_b, item_text as item_text_b, video as video_b, convert(varchar(12), '') as visibility into #t1 from
(select *, case when video Is Null then 'none' else 'visible' end as visible, ROW_NUMBER() OVER (order by item_id) as rownumber
from sam_news_perspectives where item_type = 'video' and purpose = @purpose and item_id <> @max_item_id) as subQueryAlias
where rownumber % 2 = @modulo_b

alter table #t1 alter column heading_a varchar(200) null
alter table #t1 alter column heading_b varchar(200) null

update #t1 set heading_b = null, item_text_b = null, video_b = null

select rownumber as rownumber_b, heading as heading_b, item_text as item_text_b, video as video_b into #t2 from
(select *, case when video Is Null then 'none' else 'visible' end as visible, ROW_NUMBER() OVER (order by item_id) as rownumber
from sam_news_perspectives where item_type = 'video' and purpose = @purpose and item_id <> @max_item_id) as subQueryAlias
where rownumber % 2 = @modulo_a

update #t1 set heading_b = #t2.heading_b, item_text_b = #t2.item_text_b, video_b = #t2.video_b from #t1 inner join #t2
on #t1.rownumber_a = #t2.rownumber_b + 1

update #t1 set visibility = 'display:none' where heading_b is null

select * from #t1 order by rownumber_a desc
END
go

grant execute on p_pair_videos to public
go
