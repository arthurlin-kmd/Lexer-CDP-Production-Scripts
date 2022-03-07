with
customer_spend as (
	select 
		case when dl.location_code = '196' then 'US'
			 when dl.location_code = '199' then 'NZ'
			 when dl.location_code = '299' then 'AU'
			 when dl.location_code = '799' then 'UK'
			 when fst.dim_country_key = '1' then 'NZ'
			 when fst.dim_country_key = '2' then 'AU'
			 when fst.dim_country_key = '3' then 'UK'
		end as country,
		substring(cast(fst.dim_date_key as varchar), 1, 4) cal_year,
		customer_number,
		sale_transaction,
		sum(case when fst.dim_country_key = 1 then fst.sale_amount_excl_gst
				 when fst.dim_country_key = 2 then fst.sale_amount_excl_gst*1.054
				 when fst.dim_country_key = 3 then fst.sale_amount_excl_gst*1.916
			end) as spend

	from fact_sales_trans fst
		join dim_customer		dc	on fst.dim_customer_key = dc.dim_customer_key
		join dim_location		dl	ON fst.dim_location_key = dl.dim_location_key
	where dc.customer_type = 'Summit Club'
		and dim_date_key between '20170101' and '20211231'
		and dim_gift_voucher_key = -1
	group by 
		case when dl.location_code = '196' then 'US'
			 when dl.location_code = '199' then 'NZ'
			 when dl.location_code = '299' then 'AU'
			 when dl.location_code = '799' then 'UK'
			 when fst.dim_country_key = '1' then 'NZ'
			 when fst.dim_country_key = '2' then 'AU'
			 when fst.dim_country_key = '3' then 'UK'
		end,
		substring(cast(fst.dim_date_key as varchar), 1, 4),
		customer_number,
		sale_transaction
)
select
	country,
	cal_year,
	count(distinct customer_number) as active_customers,
	sum(case when spend > 0 then spend end) as demand_revenue,
	count(distinct sale_transaction) as txn,
	sum(spend) / cast(count(distinct sale_transaction) as float) as aov,
	sum(case when spend <= 0 then spend end) as return_orders
from customer_spend
group by country, cal_year
order by country, cal_year
;


with cust_profile as (
SELECT ac.Antavo_ID						as antavo_id
,      ac.contactid						as customer_id
,      cu.customer_number        
,      s.sale_transaction        
,      d.full_date_datetime				as date_time
,      case when l.location_code = '196' then 'US'
			when l.location_code = '199' then 'NZ'
			when l.location_code = '299' then 'AU'
			when l.location_code = '799' then 'UK'
			else c.country_code            
	   end as country_code
,      l.location_code           
,      l.location_name         
,	   cu.contact_by_sms  
,	   cu.contact_by_email
,	   cu.contact_by_post
,      SUM(s.sale_qty)					as total_sale_qty
,      SUM(s.sale_amount_incl_gst)		as total_sale_amount_incl_gst
,	   SUM(s.discount_amount_incl_gst)	as total_discount_amount_incl_gst
       
FROM       [dbo].[fact_sales_trans]				s		(nolock)
INNER JOIN [dbo].[dim_customer]					cu		(nolock) ON s.dim_customer_key = cu.dim_customer_key
LEFT  JOIN [dbo].[dim_country]					c		(nolock) ON s.dim_country_key = c.dim_country_key
INNER JOIN [dbo].[dim_location]					l		(nolock) ON s.dim_location_key = l.dim_location_key
INNER JOIN [dbo].[dim_date]						d		(nolock) ON s.dim_date_key = d.dim_date_key
INNER JOIN [mkt].[antavo_contact]				ac		(nolock) ON cu.customer_number = ac.new_summitclubmemberid
																	AND cu.source_system = 'Summit'
																	AND cu.row_current_customer = 'Y'
WHERE cu.dim_customer_key > 2
	   And s.dim_date_key >= '20170101'
GROUP BY ac.Antavo_ID
,        ac.contactid
,        cu.customer_number
,        s.sale_transaction
,        d.full_date_datetime
,        case when l.location_code = '196' then 'US'
			when l.location_code = '199' then 'NZ'
			when l.location_code = '299' then 'AU'
			when l.location_code = '799' then 'UK'
			else c.country_code            
	     end  
,        l.location_code
,        l.location_name
,	     cu.contact_by_sms  
,	     cu.contact_by_email
,	     cu.contact_by_post
)
select
	country_code,
	count(distinct customer_number) as mbr_count,
	count(distinct case when contact_by_email = 1 then customer_number end) as emailable_mbr_count,
	count(distinct case when contact_by_sms = 1 then customer_number end) as sms_mbr_count,
	count(distinct case when contact_by_post = 1 then customer_number end) as postal_mbr_count
from cust_profile
group by country_code
;