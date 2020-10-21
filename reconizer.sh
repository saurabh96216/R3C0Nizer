#!/bin/bash

#colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
reset=`tput sgr0`

#argument
if [[ -z $1 ]]; then
	echo -e "$red Usage: ./reconizer.sh <domain.com>"
	exit 1
fi

if [ -d ~/recon/ ]
then
  echo " "
else
  mkdir ~/recon

fi

if [ -d ~/recon/$1 ]
then
  echo " "
else
  mkdir ~/recon/$1

fi


echo "${red}
 =================================================
|   ____  _____  ____ ___  _   _ _                |
|  |  _ \|___ / / ___/ _ \| \ | (_)_______ _ __   |
|  | |_) | |_ \| |  | | | |  \| | |_  / _ \ '__|  |
|  |  _ < ___) | |__| |_| | |\  | |/ /  __/ |     |
|  |_| \_\____/ \____\___/|_| \_|_/___\___|_|     |
|                                                 |
 ================== Anon-Artist ==================
${reset}"
echo "${blue} [+] Started Subdomain Discovery ${reset}"
echo " "

#assefinder
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -f ~/go/bin/assetfinder ]
then
  echo "${magenta} [+] Running Assetfinder ${reset}"
  assetfinder -subs-only $1  >> ~/recon/$1/assetfinder.txt 
else
  echo "${blue} [+] Installing Assetfinder ${reset}"
  echo "${magenta} [+] Running Assetfinder ${reset}"
  go get -u github.com/tomnomnom/assetfinder
  assetfinder -subs-only $1  >> ~/recon/$1/assetfinder.txt
fi
echo " "
echo "${blue} [+] Succesfully saved to assetfinder.txt  ${reset}"
echo " "

#amass
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -d ~/tools/Amass/ ]
then
  echo "${magenta} [+] Running Amass ${reset}"
  sudo  amass enum --passive -d $1 > ~/recon/$1/amass.txt
else
  echo "${blue} [+] Installing Amass ${reset}"
  echo "${magenta} [+] Running Amass ${reset}"
  sudo git clone https://github.com/OWASP/Amass.git ~/tools/Amass
  sudo amass enum --passive -d $1 > ~/recon/$1/amass.txt
fi
echo " "
echo "${blue} [+] Succesfully saved to amass.txt  ${reset}"
echo " "

#subfinder
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -f ~/go/bin/subfinder ]
then
  echo "${magenta} [+] Running Subfinder ${reset}"
    subfinder -d $1 -o ~/recon/$1/subfinder.txt 
else
  echo "${blue} [+] Installing Subfinder ${reset}"
  echo "${magenta} [+] Running Subfinder ${reset}"
  go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
  subfinder -d $1 -o ~/recon/$1/subfinder.txt
fi
echo " "
echo "${blue} [+] Succesfully saved to subfinder.txt  ${reset}"
echo " "

#find-domain
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -f ~/findomain-linux ]
then
  echo "${magenta} [+] Running Findomain ${reset}"
    findomain-linux --target $1 -u ~/recon/$1/findomain.txt
else
  echo "${blue} [+] Installing Findomain ${reset}"
  wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux
  chmod +x findomain-linux
  echo "${magenta} [+] Running Findomain ${reset}"
  findomain-linux --target $1 -u ~/recon/$1/findomain.txt
fi
echo " "
echo "${blue} [+] Succesfully saved to findomain.txt  ${reset}"
echo " "

#Sublister
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -d ~/tools/Sublist3r/ ]
then
  echo "${magenta} [+] Running Sublist3r ${reset}"
    python ~/tools/Sublist3r/sublist3r.py -d $1 -t 10 -v -o ~/recon/$1/sublist3r.txt > /dev/null
else
  echo "${blue} [+] Installing Sublist3r ${reset}"
  echo "${magenta} [+] Running Sublist3r ${reset}"
  git clone https://github.com/aboul3la/Sublist3r.git ~/tools/Sublist3r/
  python ~/tools/Sublist3r/sublist3r.py -d $1 -t 10 -v -o ~/recon/$1/sublist3r.txt > /dev/null
fi
echo " "
echo "${blue} [+] Succesfully saved to sublist3r.txt  ${reset}"
echo " "

#uniquesubdomains
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
echo "${red} [+] fetching unique domains ${reset}"
echo ""
cat ~/recon/$1/assetfinder.txt ~/recon/$1/amass.txt ~/recon/$1/subfinder.txt ~/recon/$1/findomain.txt ~/recon/$1/sublist3r.txt | sort -u >> ~/recon/$1/unique.txt
cat ~/recon/$1/unique.txt
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo ""
echo "${blue} [+] Succesfully saved to unique.txt ${reset}"

#ParamSpider
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -d ~/tools/ParamSpider/ ]
then
  echo "${magenta} [+] Running ParamSpider ${reset}"
    python3 ~/tools/ParamSpider/paramspider.py -d $1 -t 10 -v -o ~/recon/$1/paramspider.txt > /dev/null
else
  echo "${blue} [+] Installing ParamSpider ${reset}"
  echo "${magenta} [+] Running ParamSpider ${reset}"
  git clone https://github.com/devanshbatham/ParamSpider ~/tools/ParamSpider/
  python3 ~/tools/ParamSpider/paramspider.py $1 -t 10 -v -o ~/recon/$1/paramspider.txt > /dev/null
fi
echo " "
echo "${blue} [+] Succesfully saved to paramspider.txt  ${reset}"

#sorting alive subdomains
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
echo "${red} [+] sorting alive subdomains ${reset}"
echo ""
cat ~/recon/$1/unique.txt | httpx >> ~/recon/$1/all-unique-alive-subs.txt
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo ""
echo "${blue} [+] Successfully saved to all-unique-alive-subs.txt"

#screenshotting
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
echo "${red} [+] Screenshotting alive subs ${reset}"
echo ""
mkdir ~/recon/$1/screenshots
if [ -f ~/go/bin/aquatone ]
then
  echo "${magenta} [+] Running Aquatone ${reset}"
    cat ~/recon/$1/all-unique-alive-subs.txt | aquatone -out ~/recon/$1/screenshots 
else
  echo "${blue} [+] Installing Aquatone ${reset}"
  go get -u github.com/michenriksen/aquatone
  echo "${magenta} [+] Running Aquatone ${reset}"
  cat ~/recon/$1/all-unique-alive-subs.txt | aquatone -out ~/recon/$1/screenshots 
fi
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo ""
echo "${blue} [+] Successfully saved to screenshots"

#nuclei
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"
echo " "
if [ -f ~/go/bin/nuclei ]
then
 echo "${magenta} [+] Running nuclei ${reset}"
 nuclei -update-templates
 nuclei -l ~/recon/$1/unique.txt -t cves/ -t files/ -o ~/recon/$1/nuclei_results.txt
else
  echo "${blue} [+] Installing nuclei ${reset}"
  echo "${magenta} [+] Running nuclei ${reset}"
  go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
  nuclei -update-templates
nuclei -l ~/recon/$1/unique.txt -t cves/ -t files/ -o ~/recon/$1/nuclei_results.txt
fi
echo " "

echo "${red} [+] Thank you for using R3C0nizer${reset}"
echo ""
echo "${yellow} ---------------------------------- xxxxxxxx ---------------------------------- ${reset}"

