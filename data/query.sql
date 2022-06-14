WITH joined_table as (
	SELECT urls.id as url_id,
		visits.id as visits_id ,
		urls.url, 
		urls.title, 
		urls.visit_count,
		urls.typed_count, 
		urls.hidden, 
		datetime(visits.visit_time/1000000-11644473600, "unixepoch") as visit_date,
		datetime(urls.last_visit_time/1000000-11644473600, "unixepoch") as last_visit_date, 
		visits.from_visit as from_visit_id,
		(visits.visit_duration / 3600 / 1000000) ||':'|| strftime('%M:%S', visits.visit_duration / 1000000 / 86400.0) AS duration,
		visits.transition
 FROM visits
 JOIN urls ON visits.url = urls.id 
where visit_date < date('2021-01-08') and visit_date > date('2020-11-07')
)
select j.*,
	f.url as from_url,
	    CASE j.transition & 0xff
           WHEN 0
               THEN 'LINK'
           WHEN 1
               THEN 'TYPED'
           WHEN 2
               THEN 'AUTO_BOOKMARK'
           WHEN 3
               THEN 'AUTO_SUBFRAME'
           WHEN 4
               THEN 'MANUAL_SUBFRAME'
           WHEN 5
               THEN 'GENERATED'
           WHEN 6
               THEN 'START_PAGE'
           WHEN 7
               THEN 'FORM_SUBMIT'
           WHEN 8
               THEN 'RELOAD'
           WHEN 9
               THEN 'KEYWORD'
           WHEN 10
               THEN 'KEYWORD_GENERATED'
           ELSE NULL
           END     core_transition_type,
       CASE j.transition & 0xFFFFFF00
           WHEN 0x01000000
               THEN 'FORWARD_BACK'
           WHEN 0x02000000
               THEN 'FROM_ADDRESS_BAR'
           WHEN 0x04000000
               THEN 'HOME_PAGE'
           WHEN 0x10000000
               THEN 'CHAIN_START'
           WHEN 0x20000000
               THEN 'CHAIN_END'
           WHEN 0x40000000
               THEN 'CLIENT_REDIRECT'
           WHEN 0x80000000
               THEN 'SERVER_REDIRECT'
           WHEN 0xC0000000
               THEN 'IS_REDIRECT_MASK'
           ELSE NULL
           END qualifier_transition_type
 from joined_table j
 left join joined_table f 
 on j.from_visit_id = f.visits_id
order by visit_date ASC;

