<#
  .SYNOPSIS
  Converts arabic numerals into roman numerals and vice versa.

  .DESCRIPTION
  Converts the given value either in arabic numerals to roman numerals or vice
  versa. In each case the given value is checked if it is a valid arabic or 
  roman numeral. If not an exception is thrown or an error message is printed 
  to the error stream. Otherwise the converted value ist printed out. Empty 
  strings are allowed, they will be returned as 0. The given roman numerals
  are handled case insensitive.
  
  In case of success the exit code is 0 otherwise 1.
  
  Compatibility: Checked with PS 4, 5 and 6 under Win 7, 8.1, 10 and with PS.core
  under <Linux>.
  
  .PARAMETER GivenValue
  Specifies the value to convert, may be empty for converting to arabic numerals 
  because empty means 0 for roman numerals.

  .PARAMETER ToRoman
  Specifies the conversion of the given value into roman numerals.
  
  .PARAMETER ToArabic
  Specifies the conversion of the given value into arabic numerals.

  .PARAMETER DoTestrun
  Specifies to do a test run with the conversion of arabic numerals into roman
  numerals and vice versa including a check for both directions.

  .PARAMETER HaltOnError
  Specifies to throw an exception (and ahlting the script) instead writing an
  error message to the error stream.

  .INPUTS
  None. You can't pipe objects to this script.

  .OUTPUTS
  The converted numeral as roman numerals (-ToRoman) in uppercase or as arabic 
  numerals (-ToArabic) with Write-Output so it can be used as input for a pipeline.

  .EXAMPLE
  convertTest.ps1 -toroman 1998
  convertTest.ps1 1998 -toroman
  convertTest.ps1 -ToRoman "1,998"
  
  Returns all "MCMXCVIII"

  .EXAMPLE
  convertTest.ps1 -ToArabic McMxCVIii
  convertTest.ps1 MCMXCVIII -ToArabic
  
  Returns both "1998"

  .EXAMPLE
  convertTest.ps1 -ToRoman -42
  
  Throws Exception "can not convert '-42' into roman numeral!" or writes 
  "ArabicToRoman : can not convert '-42' into roman number!" to the error stream.

  .EXAMPLE
  convertTest.ps1 -ToArabic 42
  
  Throws Exception "'42' is not a roman numeral!" or writes 
  "RomanToArabic : '42' is not a roman numeral!" to the error stream.

#>

Param(
	[String][Parameter(Mandatory=$False)][AllowEmptyString()] $GivenValue = "",
	[Switch][Boolean] $ToRoman,
	[Switch][Boolean] $ToArabic,
	[Switch][Boolean] $DoTestrun,
	[Switch][Boolean] $HaltOnError
)

Import-Module "$PSScriptRoot\ConvertRomanArabNumbers.psm1" -Force -ArgumentList $HaltOnError -ErrorAction Stop -Verbose:($PSBoundParameters.Verbose -eq $true)

[int]$exitCode = 0;

If ($DoTestrun) {
	Write-Host "Check input roman numbers:`r`n";
	Foreach($aRomanNumber In "vv", "VV", "viv", "vL", "IXv", "XcL", "xiv", "vix", "viix", "XXXIX", "XXXIXv", "McMxCVIii") {
		"$aRomanNumber is valid roman: $(IsRoman $aRomanNumber)";
	}
	
	Write-Host "`r`nCheck input arabic numbers:`r`n";
	Foreach($arabicNumber In "0", "-42", "1998", "4.2", "1.23e2", "0xA0", "1,998") {
		"$arabicNumber is convertible to roman: $(IsConvertibleToRoman $arabicNumber)";
	}
	
	Write-Host "`r`nCheck both conversion functions:`r`n";
	For ($arabic = 0; $arabic -lt 101; $arabic++) {
		$roman = ArabicToRoman $arabic;
		
		If ($arabic -ne (RomanToArabic $roman)) {
			Write-Host "can't convert $roman to $arabic";
		} Else {
			Write-Host "$roman`t`t correct converted to $arabic";
		}
	}
} ElseIf ($ToRoman) {
	$result = ArabicToRoman $GivenValue;
	If ($result -eq $Null) {
		$exitCode = 1;
	} Else {
		Write-Output $result;
	}
} ElseIf ($ToArabic) {
	$result = RomanToArabic $GivenValue;
	If ($result -lt 0) {
		$exitCode = 1;
	} Else {
		Write-Output $result;
	}
} Else {
	Get-Help $PSCommandPath -Detailed
}

Remove-Module -force ConvertRomanArabNumbers

Exit $exitCode;
