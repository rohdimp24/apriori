<?php
##Old code...can be avoided

$db_hostname='localhost';
$db_database='dvirji_mygann';
$db_username='root';
$db_password='';

set_time_limit(0);

$db_server = mysql_connect($db_hostname, $db_username, $db_password);
if (!$db_server) die("Unable to connect to MYSQL: " . mysql_error());

mysql_select_db($db_database)
or die("Unable to select database: " . mysql_error());


/*$query="Select * from AmazonTransactions";
$result=mysql_query($query);
$rowsnum=mysql_num_rows($result);
$arrTransactionIds=array();
for($i=0;$i<15800;$i++)
{
	$row=mysql_fetch_row($result);
	$arr=explode("_", $row[0]);
	#print_r($arr);
	$txnId=$arr[0];
	$arr=array_splice($arr,1);
	$proArr=implode("_",$arr);
	echo $txnId."=>".$proArr."<br/>";
	#echo $proArr;
	
	echo "<br/>";
	
	$insertQuery="INSERT INTO `transactions`(`transactionId`, `productId`) VALUES ('".$txnId."','".$proArr."')";
	echo $insertQuery."<br/>";
	$resultQuery=mysql_query($insertQuery);
	if(!$resultQuery)
	{
		echo $insertQuery."<br/>";
		echo mysql_error()."<br/>";
	}

}

*/
//this will contain the transactions which contains atleast 2 products
$query="SELECT * FROM `transactions` group by transactionId having count(transactionId)>1";
$result=mysql_query($query);
$rowsnum=mysql_num_rows($result);

for($i=0;$i<$rowsnum;$i++)
{

	$row=mysql_fetch_row($result);

	$queryItem="select * from transactions where transactionId='".$row[1]."'";
	$resultItem=mysql_query($queryItem);
	$rowsnumItem=mysql_num_rows($resultItem);
	for($j=0;$j<$rowsnumItem;$j++)
	{
		$rowItem=mysql_fetch_row($resultItem);
		$insertQuery="INSERT INTO `transactionsnew`(`transactionId`, `productId`) VALUES ('".$rowItem[1]."','".$rowItem[2]."')";
		$resultQuery=mysql_query($insertQuery);
		if(!$resultQuery)
		{
			echo $insertQuery."<br/>";
			echo mysql_error()."<br/>";
		}
	
	}

	


}




//print_r($arrTransactionIds);

?>