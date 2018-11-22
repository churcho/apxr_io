defmodule ApxrIoWeb.Projects.ArtifactView do
  use ApxrIoWeb, :view

  def show_sort_info(nil), do: show_sort_info(:name)
  def show_sort_info(:name), do: "Sort: Name"
  def show_sort_info(:status), do: "Sort: Status"
  def show_sort_info(:inserted_at), do: "Sort: Recently created"
  def show_sort_info(:updated_at), do: "Sort: Recently updated"
  def show_sort_info(_param), do: nil

  def charts(data, artifact_name) do
    invocation_rate = Poison.encode!(data.invocation_rate)
    execution_duration = Poison.encode!(data.execution_duration)
    replica_scaling = Poison.encode!(data.replica_scaling)

    raw("""
      <script type="text/javascript">
        window.onload = function(){
          Highcharts.chart('artifact_stats', {
            chart: {
              zoomType: 'x'
            },
            title: {
              text: 'Invocation Rate, Replica Scaling, Execution Duration over time'
            },
            subtitle: {
              text: 'Artifact: #{artifact_name}'
            },
            xAxis: {
              title: {
                text: 'Time'
              },
              type: 'datetime'
            },
            yAxis: {
              title: {
                text: 'QTY'
              }
            },
            legend: {
              layout: 'vertical',
              align: 'right',
              verticalAlign: 'middle'
            },
            plotOptions: {
              area: {
                fillColor: {
                  linearGradient: {
                    x1: 0,
                    y1: 0,
                    x2: 0,
                    y2: 1
                  },
                  stops: [
                    [0, Highcharts.getOptions().colors[0]],
                    [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                  ]
                },
                marker: {
                  radius: 2
                },
                lineWidth: 1,
                states: {
                  hover: {
                    lineWidth: 1
                  }
                },
                threshold: null
              }
            },
            series: [{
              name: 'Invocation Rate',
              data: #{invocation_rate}
            },  {
              name: 'Replica Scaling',
              data: #{replica_scaling}
            }, {
              name: 'Execution Duration',
              data: #{execution_duration}
            }],
            responsive: {
              rules: [{
                condition: {
                  maxWidth: 500
                },
                chartOptions: {
                  legend: {
                    layout: 'horizontal',
                    align: 'center',
                    verticalAlign: 'bottom'
                  }
                }
              }]
            }
          });
        };
      </script>
    """)
  end
end
