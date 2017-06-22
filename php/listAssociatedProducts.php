<?php
$db_hostname='localhost';
$db_database='dvirji_mygann';
$db_username='root';
$db_password='';

set_time_limit(0);

$db_server = mysql_connect($db_hostname, $db_username, $db_password);
if (!$db_server) die("Unable to connect to MYSQL: " . mysql_error());

mysql_select_db($db_database)
or die("Unable to select database: " . mysql_error());

$fs=fopen("rules.txt","r");
$str="<table border='1'>";
while(($strfp = fgets($fs))!=null){
	$strfp=trim($strfp);
	//echo "<b>".$strfp."</b><br/>";
	$arr=explode("=>",$strfp);
	$lhs=trim($arr[0]);
	$rhs=trim($arr[1]);
	//echo $rhs;
	$arrLhs=explode(",",$lhs);

	$lhsItems='';
	$lhsNames='';
	$lhsAmazonIds='';
	for($i=0;$i<sizeof($arrLhs);$i++)
	{
		$queryLHS="SELECT DISTINCT(Title),ItemId,AmazonId FROM `amazontransactions` WHERE `ItemId` in ('".$arrLhs[$i]."')";
		//echo $queryLHS;
		$resultLHS=mysql_query($queryLHS);
		$rowLHS=mysql_fetch_row($resultLHS);
		//echo "<br/>";
		//echo "LHS=>".$rowLHS[0]."=>".$rowLHS[1]."=>".$rowLHS[2]."<br/>";
		if(sizeof($arrLhs)>1)
		{
			$lhsNames.=$rowLHS[0].",";
			$lhsItems.=$rowLHS[1].",";
			$lhsAmazonIds.=$rowLHS[2].",";
		}		
		else
		{
			$lhsNames=$rowLHS[0];
			$lhsItems=$rowLHS[1];
			$lhsAmazonIds=$rowLHS[2];
		}

		//$lhsItems.=$rowLHS[1].",";
		//$lhsAmazonIds.=$rowLHS[2].",";



	}

	$str.="<tr>";
	$str.="<td>".$lhsNames."</td><td>".$lhsItems."</td><td>".$lhsAmazonIds."</td>";
	$queryRHS="SELECT DISTINCT(Title),ItemId,AmazonId FROM `amazontransactions` WHERE `ItemId` in ('".$rhs."')";
	//echo $queryRHS;
	$resultRHS=mysql_query($queryRHS);
	$rowRHS=mysql_fetch_row($resultRHS);
	//echo "RHS=>".$rowRHS[0]."=>".$rowRHS[1]."=>".$rowRHS[2]."<br/>";
	
	$str.="<td>".$rowRHS[0]."</td><td>".$rowRHS[1]."</td><td>".$rowRHS[2]."</td>";
	$str.="</tr>";
	//echo "=========================================<br/>";



}
	$str.="</table>";
	echo $str;
fclose($fs);

?>