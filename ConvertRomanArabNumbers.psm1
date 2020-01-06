Param(
	[Switch][Parameter(Mandatory=$False)][Boolean] $HaltOnError = $False
)

# checks if given roman number is valid, empty means 0
Function IsRoman {

	[OutputType([Boolean])]
	Param([String] $roman)

    return ($roman -ne $Null) -and ($roman -match ("^M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$"));
}

# checks if given arabic number is valid, less than 0 or floating point is not possible and means error
Function IsConvertibleToRoman {

	[OutputType([Boolean])]
	Param([String] $arabic)

	Try {
		$result = $arabic -match "\d+" -and [Double]$arabic -eq [Long]$arabic -and [Long]$arabic -ge 0;
	}
	Catch {
		# this extra check is necessary because conversion to double fails with hex numbers
		return $arabic -match "^0x[0-9a-f]+$";
	}
	
	return $result;
}

# convert arabic numerals into roman numerals, including validity check, allow three ciphres as maximum
Function ArabicToRoman {

	[OutputType([String])]
	Param([String] $arabicNumber)
	
	If (-not (IsConvertibleToRoman $arabicNumber)) {
		[String]$errorMessage = "can not convert '$arabicNumber' into roman number!";
		
		If ($HaltOnError) {
			Throw $errorMessage;
		}

		Write-Error $errorMessage -Category InvalidArgument;

		return $Null;
	}
	
	[Long]$number = $arabicNumber;
	
	# ---------------------------------------------------------------
	[String]$romanNumber = "M"*([math]::Floor($number / 1000));
	# ---------------------------------------------------------------
	$number = $number % 1000;
	
	If ($number -ge 500) {
		If ($number -ge 900) {
			$romanNumber = $romanNumber + "CM";
			$number = $number - 900;
		} Else {
			$romanNumber = $romanNumber + "D";
			$number = $number - 500;
		}
	}

	If ($number -lt 400) {
		$romanNumber = $romanNumber + "C"*([math]::Floor($number / 100));
	} Else {
		$romanNumber = $romanNumber + "CD";
	}
	# ---------------------------------------------------------------
	$number = $number % 100;
 
	If ($number -ge 50)	{
		If ($number -ge 90) {
			$romanNumber = $romanNumber + "XC";
			$number = $number - 90;
		} Else {
			$romanNumber = $romanNumber + "L";
			$number = $number - 50;
		}
	}
	
	If ($number -lt 40) {
		$romanNumber = $romanNumber + "X"*([math]::Floor($number / 10));
	} Else {
		$romanNumber = $romanNumber + "XL";
	}
	# ---------------------------------------------------------------
	$number = $number % 10;
	
	If ($number -ge 5) {
		If ($number -eq 9) {
			$romanNumber = $romanNumber + "IX";
			return $romanNumber;
		} Else {
			$romanNumber = $romanNumber + "V";
			$number = $number - 5;
		}
	}

	If ($number -lt 4) {
		$romanNumber = $romanNumber + "I"*$number;
	} Else {
		$romanNumber = $romanNumber + "IV";
	}
	# ---------------------------------------------------------------
	
	return $romanNumber;
}

# convert roman numerals into arabic numerals, including validity check, evaluation from left to right
Function RomanToArabic {

	[OutputType([Int])]
	Param([String] $romanNumber)
	
	[long]$arab = 0;
	[char]$lastCipher = $Null;
	
	If (-not (isRoman $romanNumber)) {
		[String]$errorMessage = "'$romanNumber' is not a roman numeral!";
		
		If ($HaltOnError) {
			Throw $errorMessage;
		}

		Write-Error $errorMessage -Category InvalidArgument
		
		return -1;
	}

	Foreach($aCipher In $romanNumber.ToUpper().ToCharArray()) {
		Switch ($aCipher) {
			'I' {
				$arab += 1;
				Break;
			}
			'V' {
				If ($lastCipher -eq 'I') {
					$arab += 4 - 1;
				} Else {
					$arab += 5;
				}
				Break;
			}
			'X' {
				If ($lastCipher -eq 'I') {
					$arab += 9 - 1;
				} Else {
					$arab += 10;
				}
				Break;
			}
			'L' {
				If ($lastCipher -eq 'X') {
					$arab += 40 - 10;
				} Else {
					$arab += 50;
				}
				Break;
			}
			'C' {
				If ($lastCipher -eq 'X') {
					$arab += 90 - 10;
				} Else {
					$arab += 100;
				}
				Break;
			}
			'D' {
				If ($lastCipher -eq 'C') {
					$arab += 400 - 100;
				} Else {
					$arab += 500;
				}
				Break;
			}
			'M' {
				If ($lastCipher -eq 'C') {
					$arab += 900 - 100;
				} Else {
					$arab += 1000;
				}
				Break;
			}
		}
		
		$lastCipher = $aCipher;
	}
	
	return $arab;
}

Export-ModuleMember -Function IsRoman
Export-ModuleMember -Function IsConvertibleToRoman
Export-ModuleMember -Function ArabicToRoman
Export-ModuleMember -Function RomanToArabic
