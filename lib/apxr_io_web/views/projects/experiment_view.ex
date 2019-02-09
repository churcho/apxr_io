defmodule ApxrIoWeb.Projects.ExperimentView do
  use ApxrIoWeb, :view

  def show_sort_info(nil), do: show_sort_info(:version)
  def show_sort_info(:version), do: "Sort: Version"
  def show_sort_info(:inserted_at), do: "Sort: Recently created"
  def show_sort_info(_param), do: nil

  def charts(data) do
    raw("""
      <script type="text/javascript">
        window.onload = function(){
          Highcharts.chart('avg_fitness_vs_evaluations', {
            chart: {
              zoomType: 'xy'
            },
            title: {
              text: 'Average Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["avg_fitness_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: [{
              categories: #{inspect(Enum.find_value(data, fn g -> g["avg_fitness_vs_evaluations"] end)["evaluation_index"])},
              title: {
                text: 'Evaluations',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
            yAxis: [{
              labels: {
                format: '{value}',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              },
              title: {
                text: 'Fitness',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
          
            tooltip: {
              shared: true
            },
          
            series: [{
              name: 'Average Fitness',
              type: 'spline',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_fitness_vs_evaluations"] end)["avg_fitness"])},
              tooltip: {
                pointFormat: '<span style="font-weight: bold; color: {series.color}">Fitness</span>: <b>{point.y}</b> '
              }
            }, {
              name: 'Fitness STD',
              type: 'errorbar',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_fitness_vs_evaluations"] end)["fitness_std"])},
              tooltip: {
                pointFormat: '(range: {point.low}-{point.high})<br/>'
              }
            }]
          });

          Highcharts.chart('avg_neurons_vs_evaluations', {
            chart: {
              zoomType: 'xy'
            },
            title: {
              text: 'Average Neurons vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["avg_neurons_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: [{
              categories: #{inspect(Enum.find_value(data, fn g -> g["avg_neurons_vs_evaluations"] end)["evaluation_index"])},
              title: {
                text: 'Evaluations',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
            yAxis: [{
              labels: {
                format: '{value}',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              },
              title: {
                text: 'Neurons',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
          
            tooltip: {
              shared: true
            },
          
            series: [{
              name: 'Average Neurons',
              type: 'spline',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_neurons_vs_evaluations"] end)["avg_neurons"])},
              tooltip: {
                pointFormat: '<span style="font-weight: bold; color: {series.color}">Neurons</span>: <b>{point.y}</b> '
              }
            }, {
              name: 'Neurons STD',
              type: 'errorbar',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_neurons_vs_evaluations"] end)["neurons_std"])},
              tooltip: {
                pointFormat: '(range: {point.low}-{point.high})<br/>'
              }
            }]
          });

          Highcharts.chart('avg_diversity_vs_evaluations', {
            chart: {
              zoomType: 'xy'
            },
            title: {
              text: 'Average Diversity vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["avg_diversity_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: [{
              categories: #{inspect(Enum.find_value(data, fn g -> g["avg_diversity_vs_evaluations"] end)["evaluation_index"])},
              title: {
                text: 'Evaluations',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
            yAxis: [{
              labels: {
                format: '{value}',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              },
              title: {
                text: 'Diversity',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
          
            tooltip: {
              shared: true
            },
          
            series: [{
              name: 'Average Diversity',
              type: 'spline',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_diversity_vs_evaluations"] end)["avg_diversity"])},
              tooltip: {
                pointFormat: '<span style="font-weight: bold; color: {series.color}">Diversity</span>: <b>{point.y}</b> '
              }
            }, {
              name: 'Diversity STD',
              type: 'errorbar',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_diversity_vs_evaluations"] end)["diversity_std"])},
              tooltip: {
                pointFormat: '(range: {point.low}-{point.high})<br/>'
              }
            }]
          });

          Highcharts.chart('max_fitness_vs_evaluations', {
            chart: {
              type: 'line'
            },
            title: {
              text: 'Max Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["max_fitness_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: {
              categories: #{inspect(Enum.find_value(data, fn g -> g["max_fitness_vs_evaluations"] end)["evaluation_index"])}
            },
            yAxis: {
              title: {
                text: 'Fitness'
              },
              labels: {
                format: '{value:.2f}'
              }
            },
            plotOptions: {
              line: {
                dataLabels: {
                  enabled: true
                },
                enableMouseTracking: false
              }
            },
            series: [{
              name: 'Max Fitness',
              data: #{inspect(Enum.find_value(data, fn g -> g["max_fitness_vs_evaluations"] end)["max_fitness"])}
            }]
          });

          Highcharts.chart('avg_max_fitness_vs_evaluations', {
            chart: {
              type: 'line'
            },
            title: {
              text: 'Average Max Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["avg_max_fitness_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: {
              categories: #{inspect(Enum.find_value(data, fn g -> g["avg_max_fitness_vs_evaluations"] end)["evaluation_index"])}
            },
            yAxis: {
              title: {
                text: 'Fitness'
              },
              labels: {
                format: '{value:.2f}'
              }
            },
            plotOptions: {
              line: {
                dataLabels: {
                  enabled: true
                },
                enableMouseTracking: false
              }
            },
            series: [{
              name: 'Average Max Fitness',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_max_fitness_vs_evaluations"] end)["maxavg_fitness"])}
            }]
          });

          Highcharts.chart('avg_min_fitness_vs_evaluations', {
            chart: {
              type: 'line'
            },
            title: {
              text: 'Average Min Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["avg_min_fitness_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: {
              categories: #{inspect(Enum.find_value(data, fn g -> g["avg_min_fitness_vs_evaluations"] end)["evaluation_index"])}
            },
            yAxis: {
              title: {
                text: 'Fitness'
              },
              labels: {
                format: '{value:.2f}'
              }
            },
            plotOptions: {
              line: {
                dataLabels: {
                  enabled: true
                },
                enableMouseTracking: false
              }
            },
            series: [{
              name: 'Average Min Fitness',
              data: #{inspect(Enum.find_value(data, fn g -> g["avg_min_fitness_vs_evaluations"] end)["min_fitness"])}
            }]
          });

          Highcharts.chart('specie_pop_turnover_vs_evaluations', {
            chart: {
              type: 'line'
            },
            title: {
              text: 'Specie-Population Turnover Vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{inspect(Enum.find_value(data, fn g -> g["specie_pop_turnover_vs_evaluations"] end)["morphology"])}'
            },
            xAxis: {
              categories: #{inspect(Enum.find_value(data, fn g -> g["specie_pop_turnover_vs_evaluations"] end)["evaluation_index"])}
            },
            yAxis: {
              title: {
                text: 'Turnover'
              }
            },
            plotOptions: {
              line: {
                dataLabels: {
                  enabled: true
                },
                enableMouseTracking: false
              }
            },
            series: [{
              name: 'Specie-Population Turnover',
              data: #{inspect(Enum.find_value(data, fn g -> g["specie_pop_turnover_vs_evaluations"] end)["evaluations"])}
            }]
          });

          Highcharts.chart('validation_avg_fitness_vs_evaluations', {
            chart: {
              zoomType: 'xy'
            },
            title: {
              text: 'Validation Average Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{
      inspect(Enum.find_value(data, fn g -> g["validation_avg_fitness_vs_evaluations"] end)["morphology"])
    }'
            },
            xAxis: [{
              categories: #{
      inspect(Enum.find_value(data, fn g -> g["validation_avg_fitness_vs_evaluations"] end)["evaluation_index"])
    },
              title: {
                text: 'Evaluations',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
            yAxis: [{
              labels: {
                format: '{value}',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              },
              title: {
                text: 'Fitness',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }],
          
            tooltip: {
              shared: true
            },
          
            series: [{
              name: 'Validation Average Fitness',
              type: 'spline',
              data: #{inspect(Enum.find_value(data, fn g -> g["validation_avg_fitness_vs_evaluations"] end)["validation_fitness"])},
              tooltip: {
                pointFormat: '<span style="font-weight: bold; color: {series.color}">Fitness</span>: <b>{point.y}</b> '
              }
            }, {
              name: 'Fitness STD',
              type: 'errorbar',
              data: #{
      inspect(Enum.find_value(data, fn g -> g["validation_avg_fitness_vs_evaluations"] end)["validation_fitness_std"])
    },
              tooltip: {
                pointFormat: '(range: {point.low}-{point.high})<br/>'
              }
            }]
          });

          Highcharts.chart('validation_max_fitness_vs_evaluations', {
            chart: {
              type: 'line'
            },
            title: {
              text: 'Validation Max Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{
      inspect(Enum.find_value(data, fn g -> g["validation_max_fitness_vs_evaluations"] end)["morphology"])
    }'
            },
            xAxis: {
              categories: #{
      inspect(Enum.find_value(data, fn g -> g["validation_max_fitness_vs_evaluations"] end)["evaluation_index"])
    }
            },
            yAxis: {
              title: {
                text: 'Fitness'
              },
              labels: {
                format: '{value:.2f}'
              }
            },
            plotOptions: {
              line: {
                dataLabels: {
                  enabled: true
                },
                enableMouseTracking: false
              }
            },
            series: [{
              name: 'Validation Max Fitness',
              data: #{
      inspect(Enum.find_value(data, fn g -> g["validation_max_fitness_vs_evaluations"] end)["validationmax_fitness"])
    }
            }]
          });

          Highcharts.chart('validation_min_fitness_vs_evaluations', {
            chart: {
              type: 'line'
            },
            title: {
              text: 'Validation Min Fitness vs Evaluations'
            },
            subtitle: {
              text: 'Morphology: #{
      inspect(Enum.find_value(data, fn g -> g["validation_min_fitness_vs_evaluations"] end)["morphology"])
    }'
            },
            xAxis: {
              categories: #{
      inspect(Enum.find_value(data, fn g -> g["validation_min_fitness_vs_evaluations"] end)["evaluation_index"])
    }
            },
            yAxis: {
              title: {
                text: 'Fitness'
              },
              labels: {
                format: '{value:.2f}'
              }
            },
            plotOptions: {
              line: {
                dataLabels: {
                  enabled: true
                },
                enableMouseTracking: false
              }
            },
            series: [{
              name: 'Validation Min Fitness',
              data: #{
      inspect(Enum.find_value(data, fn g -> g["validation_min_fitness_vs_evaluations"] end)["validationmin_fitness"])
    }
            }]
          });
        }    
      </script>
    """)
  end
end
