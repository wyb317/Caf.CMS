USE [Caf.Sys3]
GO
/****** Object:  StoredProcedure [dbo].[GetSerialNo]    Script Date: 2015/6/8 10:45:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[GetSerialNo]   

(   
    @Code varchar(50)   
)   
  as 
--exec GetSerialNo  

begin 
   Declare @Value varchar(100),   
		   @DefaultValue varchar(100),
		   @SerialRuleFormatId bigint, 
           @dToday datetime,  
		   @RandNum int,         
           @Prefix varchar(20)  --这个代表前缀 
   Begin Tran     

   Begin Try   

 -- 定该条记录，好多人用lock去锁，起始这里只要执行一句update就可以了 

 --在同一个事物中，执行了update语句之后就会启动锁 

 Update SerialRule set Value=Value where Code=@Code   

     Select @Value = Value,@SerialRuleFormatId = SerialRuleFormatId,@Prefix = Prefix,@DefaultValue=DefaultValue,@RandNum=RandNum From SerialRule where Code=@Code    

     -- 因子表中没有记录，插入初始值  

     If @Value is null   

     Begin 
		If @SerialRuleFormatId=2
		begin
        Select @Value = convert(bigint, convert(varchar(6), getdate(), 12) + @DefaultValue)  
		end else if  @SerialRuleFormatId=3
		begin
		 Select @Value = right(1000000+cast(rand()*10000 as int)+1,@RandNum) 
		End else  
		Begin
		Select @Value =@DefaultValue
		End
       Update SerialRule set Value=@Value where Code=@Code   
     end else   

     Begin --因子表中没 有记录  

	 If @SerialRuleFormatId=2
	 Begin
      Select @dToday = substring(@Value,1,6)   

       --如果日期相等，则加1  
       If @dToday = convert(varchar(6), getdate(), 12)   
         Select @Value = convert(varchar(16), (convert(bigint, @Value) + 1))   

       else --如果日期不 相等，则先赋值日期，流水号从1开始  
         Select @Value = convert(bigint, convert(varchar(6), getdate(), 12) +@DefaultValue)   
	 end else if  @SerialRuleFormatId=3
	 begin
	  Select @Value = right(1000000+cast(rand()*10000 as int)+1,@RandNum) 
	 End else  
	 Begin
	  Select @Value = convert(varchar(16), (convert(bigint, @Value) + 1))   
	 End 
       Update SerialRule set Value =@Value where Code=@Code   
     End 

     Select result = ISNULL (@Prefix,'')+@Value     
	 --Select result =@Value  
     Commit Tran   
   End Try   

   Begin Catch   
     Rollback Tran   
     Select result = 'Error' 
   End Catch   
end


