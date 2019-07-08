#XAML
$inputXML = @"
<Window x:Class="WpfApp1.Window4"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:sys="clr-namespace:System;assembly=mscorlib"
        mc:Ignorable="d"
        Title="Combobox in DataGrid" Height="450" Width="800">
    <Grid>
        <DataGrid x:Name="DataGrid" AutoGenerateColumns="False" HorizontalAlignment="Left" Height="399" Margin="10,10,0,0" VerticalAlignment="Top" Width="772">
            <DataGrid.RowHeaderTemplate>
                <DataTemplate>
                    <Grid>
                        <CheckBox IsChecked="{Binding Path=IsSelected, Mode=TwoWay,
                                    RelativeSource={RelativeSource FindAncestor,
                                    AncestorType={x:Type DataGridRow}}}" Margin="0,0,0,0">
                            <CheckBox.LayoutTransform>
                                <ScaleTransform ScaleX="1" ScaleY="1" />
                            </CheckBox.LayoutTransform>
                        </CheckBox>
                    </Grid>
                </DataTemplate>
            </DataGrid.RowHeaderTemplate>
            <DataGrid.Columns>
                <DataGridTemplateColumn Header="Combobox" Visibility="Visible" Width="300">
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate>
                               <ComboBox
                               ItemsSource="{Binding Path=Combobox}"
                               SelectedItem="{Binding Path=Result, Mode=OneWay, UpdateSourceTrigger=PropertyChanged}">
                            </ComboBox>
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
                <DataGridTemplateColumn Header="Hostname" Visibility="Visible" Width="100">
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate>
                            <Label Content="{Binding Hostname}" >
                            </Label>
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
                <DataGridTemplateColumn Header="IP" Visibility="Visible" Width="100">
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate>
                            <Label Content="{Binding IP}" >
                            </Label>
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
                <DataGridTemplateColumn Header="MAC" Visibility="Visible" Width="100">
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate>
                            <Label Content="{Binding MAC}" >
                            </Label>
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
            </DataGrid.Columns>
        </DataGrid>
    </Grid>
</Window>
"@
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $Form = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
    Write-Warning ("Unable to parse XML, with error: $($Error[0])`n" +
                   "Ensure that there are NO SelectionChanged or " +
                   "TextChanged properties in your textboxes (PowerShell cannot process them)")
    throw
}


#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { "trying item $($_.Name)";
    try { Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop }
    catch { throw }
}
 
function Get-FormVariables {
    if ($global:ReadmeDisplay -ne $true) { 
        Write-Host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow
        $global:ReadmeDisplay = $true 
    }
    Write-Host "Found the following interactable elements from our form" -ForegroundColor Cyan
    Get-Variable WPF*
}
 
Get-FormVariables


#===========================================================================
# Load Data into DataGrid
#===========================================================================

class myRow{
[Array]$Combobox
[string]$Hostname
}

$test1 = New-Object myRow -Property @{Hostname = "test1"; Combobox = "TEST1","TEST2" }



$WPFDataGrid.ItemsSource = @($test1)
#===========================================================================
# Shows the form
#===========================================================================
$async = $Form.Dispatcher.InvokeAsync( {
        $Form.ShowDialog() | Out-Null

})

$async.Wait() | Out-Null  
