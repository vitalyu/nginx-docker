package main


import (
    "text/template"
    "os"
    "flag"
    "strings"
    "fmt"
)


type Site struct {
    // exported field since it begins
    // with a capital letter
    Server string
    Auth_accessfabric_audience string
    Proxy_pass string
}


var sites []Site


func Handle(err error) {
//
// Error handler
//
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s", err)
		os.Exit(1)
	}
}

func SitesFromENVs(){
//
// Looking for ACF* envs 
// and append values to sites []Site array
//
    for i := 0; i < 100; i++ { // ACF0 .. ACF99
        acf_key  := fmt.Sprintf("ACF%d",i)
        acf_val_ := os.Getenv(acf_key)

        if len(acf_val_) < 1 { continue } // if ACF* exists
        
        acf_val := strings.Split(acf_val_, "|")
        if len(acf_val)  < 3 { continue } // if 3 sections exists in ACF* value

        site := Site{ 
            Server: acf_val[0] ,
            Auth_accessfabric_audience: strings.Trim( acf_val[1]," " ) ,
            Proxy_pass: acf_val[2] ,
        }
        sites = append(sites, site)
    }
}


func PrintSites(s []Site) {
//
//  Print sites data and length
//  For debug
//
    fmt.Fprintf(os.Stderr, "len=%d cap=%d %v\n", len(s), cap(s), s)
}


func RenderTemplate(tmplFname string){
    tmpl := template.New("nginx.conf template")

    tmpl, err := template.ParseFiles( tmplFname )
    Handle(err)

    err = tmpl.Execute(os.Stdout, sites)
    Handle(err)
}


func main() {    
    tmplFname := flag.String("tmpl", "", "ex: -tmpl ./nginx.conf.tmpl")
    debug := flag.Bool("debug", false, "ex: -debug")
    flag.Usage = func(){
        fmt.Fprintf(os.Stderr, "\nUsage: ./env-to-nginx\n\n" )
        flag.PrintDefaults()
        fmt.Fprintf(os.Stderr, "\nExample:\n")
        fmt.Fprintf(os.Stderr, "\texport   ACF0='server1 | auth_accessfabric_audience1 | proxy_pass1'\n")
        fmt.Fprintf(os.Stderr, "\texport   ACF1='server2 | auth_accessfabric_audience2 | proxy_pass2'\n")
        fmt.Fprintf(os.Stderr, "\texport  ACF30='server30| auth_accessfabric_audience30| proxy_pass30'\n")
        fmt.Fprintf(os.Stderr, "\n\t./env-to-nginx -debug -tmpl ./nginx.conf.tpl > /etc/nginx/nginx.conf\n\n")
    }
    flag.Parse()

    if len( *tmplFname ) <= 0 {
        flag.Usage()
        os.Exit(1)
    }

    SitesFromENVs()

    if *debug { 
        PrintSites(sites) 
    }

    RenderTemplate( *tmplFname )
}