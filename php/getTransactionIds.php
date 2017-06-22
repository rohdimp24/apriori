<?php
## file to find the transaction Id fro the amazon transactions. 
# this is the input data for the apriori to work

$db_hostname='localhost';
$db_database='apriori';
$db_username='root';
$db_password='';

set_time_limit(0);

$db_server = mysql_connect($db_hostname, $db_username, $db_password);
if (!$db_server) die("Unable to connect to MYSQL: " . mysql_error());

mysql_select_db($db_database)
or die("Unable to select database: " . mysql_error());

#Dont do anything if the selling date < 22nd september
$query="Select * from amazontransactions where SellingDate < '2015-09-22' ";
$result = mysql_query($query);
$num_rows = mysql_num_rows($result);
for($i=0;$i<$num_rows;$i++)
{

	$row=mysql_fetch_row($result);
	$txId=$row[0];

	#break it at _
	// $arr=explode("_",$txId);

	#insert the actual transaction
	$queryUpdate="UPDATE `amazontransactions` SET `transactionId`='".$txId."' where Id='".$txId."'";
	$resultUpdate=mysql_query($queryUpdate);

}

#get the transaction Ids
$query="Select * from amazontransactions where SellingDate > '2015-09-22' ";
$result = mysql_query($query);
$num_rows = mysql_num_rows($result);
for($i=0;$i<$num_rows;$i++)
{

	$row=mysql_fetch_row($result);
	$txId=$row[0];

	#break it at _
	$arr=explode("_",$txId);

	#insert the actual transaction
	$queryUpdate="UPDATE `amazontransactions` SET `transactionId`='".$arr[0]."' where Id='".$txId."'";
	$resultUpdate=mysql_query($queryUpdate);

}





?>